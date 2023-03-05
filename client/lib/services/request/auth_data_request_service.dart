import 'dart:async';
import 'dart:convert';

import 'package:solidtrade/data/dtos/auth/response/check_magic_link_status_response_dto.dart';
import 'package:solidtrade/data/dtos/auth/response/create_magic_link_response_dto.dart';
import 'package:solidtrade/data/models/common/constants.dart';
import 'package:solidtrade/data/models/request_response/request_response.dart';
import 'package:solidtrade/services/request/base/base_request_service.dart';

class AuthDataRequestService extends IBaseRequestService {
  Future<RequestResponse<CreateMagicLinkResponseDto>> createMagicLink(
    String email,
  ) async {
    var body = json.encode({
      'Email': email,
    });
    return await makeRequest<CreateMagicLinkResponseDto>(
      HttpMethod.post,
      Constants.endpointAuth,
      mustBeAuthenticated: false,
      body: body,
    ).create((data) => CreateMagicLinkResponseDto.fromJson(data));
  }

  Future<RequestResponse<CheckMagicLinkStatusResponseDto>> checkMagicLinkStatus(
    String guid,
  ) async {
    return await makeRequest<CheckMagicLinkStatusResponseDto>(
      HttpMethod.get,
      '${Constants.endpointAuth}status',
      mustBeAuthenticated: false,
      queryParameters: {
        'confirmationStatusCode': guid,
      },
    ).create((data) => CheckMagicLinkStatusResponseDto.fromJson(data));
  }
}
