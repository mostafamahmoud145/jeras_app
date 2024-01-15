
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:jeras/api/http_helper.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/enums/http_reponse_status.dart';
import 'package:jeras/methods/checkinternet.dart';
import 'package:jeras/models/failure_model.dart';



class AuthenticationRepo {

  Future<Either<FailureModel, Map>> login()async{
    try{
      /// check the internet connection.
      if (await isConnectedToInternet()){

        Map<String, dynamic> data = {
          "username":"uf+#991h0YPh",
          "password":"6*&]j50f]{L!"
        };

        http.Response response= await HttpHelper.postData(linkUrl: AppConstants.loginEndPoint, data: data);

        print('resp: ${jsonDecode(response.body)}');
        if(response.statusCode==200 || response.statusCode==201){
          return Right(jsonDecode(response.body));

        }else if(response.statusCode==400){
          /// bad request(invalid data).
          String message= jsonDecode(response.body)['message'];
          return Left(FailureModel(responseStatus: HttpResponseStatus.invalidData, message: message));

        }else{
          return Left(FailureModel(responseStatus: HttpResponseStatus.failure));
        }

      }else{
        return Left(FailureModel(responseStatus: HttpResponseStatus.noInternet));
      }
    }catch (e){
      print('login error: $e');
      return Left(FailureModel(responseStatus: HttpResponseStatus.failure));
    }
  }


  Future<Either<FailureModel, Map>> generateOTP({
  required String token,
   required String countryCode,
   required String phoneNumber
})async{

    try{
      /// check the internet connection.
      if (await isConnectedToInternet()){

        Map<String, dynamic> data = {
          "countryCode": countryCode,
          "phoneNumber": phoneNumber
        };

        http.Response response= await HttpHelper.postData(
            linkUrl: AppConstants.generateOTPEndPoint,
            data: data,
          token: token
        );

        if(response.statusCode==200 || response.statusCode==201){
          return Right(jsonDecode(response.body));

        }else if(response.statusCode==400 || response.statusCode==401){
          /// bad request(invalid data).
          String message= jsonDecode(response.body)['message'];
          return Left(FailureModel(responseStatus: HttpResponseStatus.invalidData, message: message));

        }else{
          return Left(FailureModel(responseStatus: HttpResponseStatus.failure));
        }

      }else{
        return Left(FailureModel(responseStatus: HttpResponseStatus.noInternet));
      }
    }catch (e){
      return Left(FailureModel(responseStatus: HttpResponseStatus.failure));
    }
  }




  Future<Either<FailureModel, Map>> verifyOTP({
    required String otpCode,
    required String phoneNumber,
    required String countryCode,
    required String token,
  })async{

    try{
      /// check the internet connection.
      if (await isConnectedToInternet()){

        Map<String, dynamic> data = {
          "enteredOtp": otpCode,
          "phoneNumber": phoneNumber,
          "countryCode": countryCode,
        };

        http.Response response= await HttpHelper.postData(
            linkUrl: AppConstants.verifyOTPEndPoint,
            data: data,
            token: token
        );


        if(response.statusCode==200 || response.statusCode==201){
          return Right(jsonDecode(response.body));

        }else if(response.statusCode==400){
          /// bad request(invalid data).
          String message= jsonDecode(response.body)['message'];
          return Left(FailureModel(responseStatus: HttpResponseStatus.invalidData, message: message));

        }else{
          return Left(FailureModel(responseStatus: HttpResponseStatus.failure));
        }

      }else{
        return Left(FailureModel(responseStatus: HttpResponseStatus.noInternet));
      }
    }catch (e){
      return Left(FailureModel(responseStatus: HttpResponseStatus.failure));
    }
  }
}