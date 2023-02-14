using Application.Common.Interfaces.Services;
using Application.Models.Dtos.User.Request;
using Microsoft.AspNetCore.Mvc;
using static Application.Common.ApplicationConstants;
using static WebAPI.Common.MatchOneOfResult;

namespace WebAPI.Controllers;

[ApiController]
[Route("/users")]
public class UserController : Controller
{
    private readonly IUserService _userService;

    public UserController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpPost]
    public async Task<IActionResult> CreateUser([FromForm] CreateUserRequestDto dto)
        => MatchResult(await _userService.CreateUser(dto, Request.Headers[UidHeader]));
        
    [HttpGet("me")]
    public async Task<IActionResult> GetMe()
        => MatchResult(await _userService.GetUserByUid(Request.Headers[UidHeader], Request.Headers[UidHeader]));
        
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
        => MatchResult(await _userService.GetUserById(id, Request.Headers[UidHeader]));
        
    [HttpGet("{username}")]
    public async Task<IActionResult> GetByUsername(string username)
        => MatchResult(await _userService.SearchUserByUsername(username, Request.Headers[UidHeader]));
        
    [HttpGet]
    public async Task<IActionResult> GetByUid([FromQuery] GetUserByUidRequestDto dto)
        => MatchResult(await _userService.GetUserByUid(dto.Uid, Request.Headers[UidHeader]));

    [HttpPatch]
    public async Task<IActionResult> UpdateUser([FromForm] UpdateUserDto dto)
        => MatchResult(await _userService.UpdateUser(dto, Request.Headers[UidHeader]));

    [HttpDelete]
    public async Task<IActionResult> DeleteUser()
        => MatchResult(await _userService.DeleteUser(Request.Headers[UidHeader]));
}