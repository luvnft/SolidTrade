using Application.Common;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Storage;
using Application.Common.Interfaces.Services;
using Application.Errors.User;
using Application.Models.Dtos.User.Request;
using Application.Models.Dtos.User.Response;
using Application.Models.Types;
using AutoMapper;
using Domain.Entities;
using Microsoft.AspNetCore.Http;
using Serilog;
using Success = OneOf.Types.Success;

namespace Application.Services;

public class UserService : IUserService
{
    private readonly ILogger _logger = Log.ForContext<UserService>();
        
    private readonly IMediaManagementService _mediaManagementService;
    private readonly IIdentityService _identityService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
        
    public UserService(IMapper mapper, IMediaManagementService mediaManagementService, IIdentityService identityService, IUnitOfWork unitOfWork)
    {
        _mediaManagementService = mediaManagementService;
        _identityService = identityService;
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }

    public async Task<Result<UserResponseDto>> CreateUser(CreateUserRequestDto dto, string uid)
    {
        var user = new User
        {
            Bio = $"Hi, I'm {dto.DisplayName} and this is my Portfolio. 👋",
            Email = dto.Email,
            Uid = uid,
            Username = dto.Username,
            DisplayName = dto.DisplayName,
            Portfolio = new Portfolio
            {
                Cash = dto.InitialBalance,
                InitialCash = dto.InitialBalance,
            },
            HistoricalPositions = new List<HistoricalPosition>(),
            HasPublicPortfolio = true,
        };

        if ((await _unitOfWork.Users.IsUsernameAvailable(user.Username)).TryPickError(out var error, out var usernameAvailable))
            return error;
        if (!usernameAvailable)
            return UsernameNotAvailable.Default(user.Username);

        if ((await _unitOfWork.Users.IsUidAvailable(user.Uid)).TryPickError(out error, out var uidAvailable))
            return error;
        if (!uidAvailable)
            return UidNotAvailable.Default(user.Uid);
            
        if ((await _unitOfWork.Users.IsEmailAvailable(user.Email)).TryPickError(out error, out var emailAvailable))
            return error;
        if (!emailAvailable)
            return EmailNotAvailable.Default(user.Email);
        
        string profilePictureUri;
        if (dto.ProfilePictureFile is not null)
        {
            if ((await CreateUserProfilePictureWithFile(dto.ProfilePictureFile, uid)).TryPickError(out error, out var uri))
                return error;
            profilePictureUri = uri.AbsoluteUri;
        }
        else
        {
            if ((await CreateUserProfilePictureWithSeed(dto.ProfilePictureSeed, uid)).TryPickError(out error, out var uri))
                return error;
            profilePictureUri = uri.AbsoluteUri;
        }

        user.ProfilePictureUrl = profilePictureUri;

        _unitOfWork.Users.Add(user);
        if ((await _unitOfWork.Commit()).TryPickError(out error, out _))
            return error;

        _logger.Information("User with uid {@Uid} was created successfully", uid);
        // TODO: Check if the field if filled with ids and stuff.
        return _mapper.Map<UserResponseDto>(user);
    }
        
    public async Task<Result<UserResponseDto>> GetUserById(int id, string uid)
    {
        if ((await _unitOfWork.Users.FindByIdAsync(id)).TryPickError(out var error, out var user))
            return error;
            
        var userResponse = _mapper.Map<UserResponseDto>(user);

        // If request user is not owner of user hide private information.
        if (user.Uid != uid)
            userResponse.Email = null;

        _logger.Information("User with user uid {@Uid} fetched users with user id {@UserId} successfully", uid, id);
        return userResponse;
    }
        
    public async Task<Result<UserResponseDto>> GetUserByUid(string queriedUid, string uid)
    {
        if ((await _unitOfWork.Users.FindUserByUid(queriedUid)).TryPickError(out var error, out var user))
            return error;

        var userResponse = _mapper.Map<UserResponseDto>(user);

        // If request user is not owner of user hide private information.
        if (uid != user.Uid)
            userResponse.Email = null;

        _logger.Information("User with user uid {@Uid} fetched by uid {@QueriedUid} successfully", uid, queriedUid);
        return userResponse;
    }
        
    public async Task<Result<IEnumerable<UserResponseDto>>> SearchUserByUsername(string username, string uid)
    {
        if ((await _unitOfWork.Users.FindUsersByUsername(username)).TryPickError(out var error, out var users))
            return error;

        _logger.Information("User with user uid {@Uid} fetched {@NumberOfFoundUsers} users by username {@Username} successfully", uid, users.Count, username);
        return users.Select(user =>
        {
            // If request user is not owner of user hide private information.
            if (user.Uid != uid)
                user.Email = null;
            return _mapper.Map<UserResponseDto>(user);
        }).ToList();
    }
        
    public async Task<Result<UserResponseDto>> UpdateUser(UpdateUserDto dto, string uid)
    {
        if ((await _unitOfWork.Users.FindUserByUid(uid)).TryPickError(out var error, out var user))
            return error;
        
        if ((await _unitOfWork.Users.IsUsernameAvailable(dto.Username)).TryPickError(out error,
                out var usernameAvailable))
            return error;
        if (!usernameAvailable)
            return UsernameNotAvailable.Default(dto.Username);

        if ((await _unitOfWork.Users.IsEmailAvailable(dto.Email)).TryPickError(out error, out var emailAvailable))
            return error;
        if (!emailAvailable)
            return EmailNotAvailable.Default(dto.Email);
        
        string newProfilePicture = null;
        if (dto.ProfilePictureFile is not null)
        {
            var result = await CreateUserProfilePictureWithFile(dto.ProfilePictureFile, uid);
            if (result.TryPickT1(out error, out var uri))
                return error;

            newProfilePicture = uri.AbsoluteUri;
        }
        else if (dto.ProfilePictureSeed is not null)
        {
            var result = await CreateUserProfilePictureWithSeed(dto.ProfilePictureSeed, uid);
            if (result.TryPickT1(out error, out var uri))
                return error;
                
            newProfilePicture = uri.AbsoluteUri;
        }

        var currentProfilePicture = user.ProfilePictureUrl;
        user.Bio = dto.Bio ?? user.Bio;
        user.Email = dto.Email ?? user.Email;
        user.Username = dto.Username ?? user.Username;
        user.DisplayName = dto.DisplayName ?? user.DisplayName;
        user.HasPublicPortfolio = dto.PublicPortfolio ?? user.HasPublicPortfolio;

        if (newProfilePicture is not null)
            user.ProfilePictureUrl = newProfilePicture;
        
        _unitOfWork.Users.Update(user);
        if ((await _unitOfWork.Commit()).TryPickError(out error, out _))
            return error;

        // If the user has updated its profile picture. We delete the old one
        if (newProfilePicture is not null)
        {
            if ((await DeleteUserProfilePicture(currentProfilePicture)).TryPickError(out error, out _))
                _logger.Warning(ApplicationConstants.LogMessageTemplate, error);
        }
                
        return _mapper.Map<UserResponseDto>(user);
    }

    public async Task<Result<DeleteUserResponseDto>> DeleteUser(string uid)
    {
        if ((await _unitOfWork.Users.FindUserByUid(uid)).TryPickError(out var error, out var user))
            return error;

        if ((await _identityService.DeleteUser(uid)).TryPickError(out error, out _))
            return error;

        _unitOfWork.Users.Remove(user);
        if ((await _unitOfWork.Commit()).TryPickError(out error, out _))
            return error;
        
        await DeleteUserProfilePicture(user.ProfilePictureUrl);
    
        return new DeleteUserResponseDto { Successful = true };
    }

    private async Task<Result<Uri>> CreateUserProfilePictureWithSeed(string seed, string uid)
        => await _mediaManagementService.UploadProfilePicture($"https://avatars.dicebear.com/api/micah/{seed}.svg",
            uid);

    private async Task<Result<Uri>> CreateUserProfilePictureWithFile(IFormFile file, string uid)
        => await _mediaManagementService.UploadProfilePicture(file, uid);

    private async Task<Result<Success>> DeleteUserProfilePicture(string profilePictureUrl)
        => await _mediaManagementService.DeleteImage(profilePictureUrl);
}