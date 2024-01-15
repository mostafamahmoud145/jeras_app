
part of 'account_bloc.dart';

@immutable
abstract class AccountEvent {}

class GetLoggedUserEvent extends AccountEvent {
  GetLoggedUserEvent();

  @override
  String toString() => 'GetLoggedUserEvent';
}
class GetAccountDetailsEvent extends AccountEvent {
  final String uid, ConsultId;
  GetAccountDetailsEvent(this.uid, this.ConsultId);

  @override
  String toString() => 'GetAccountDetailsEvent';
}
class GetSettingEvent extends AccountEvent {
  GetSettingEvent();

  @override
  String toString() => 'GetSettingEvent';
}
//-------------
class GetConsultPackagesEvent extends AccountEvent {
  final String uid;
  GetConsultPackagesEvent(this.uid);

  @override
  String toString() => 'GetAccountDetailsEvent';
}

class GetConsultInfoEvent extends AccountEvent {
  final String uid;
  GetConsultInfoEvent(this.uid);

  @override
  String toString() => 'GetAccountDetailsEvent';
}
class GetCourseDetailsEvent extends AccountEvent {
  final String courseId;
  GetCourseDetailsEvent(this.courseId);

  @override
  String toString() => 'GetCourseDetailsEvent';
}
class GetConsultReviewsEvent extends AccountEvent {
  final String uid;
  GetConsultReviewsEvent(this.uid);

  @override
  String toString() => 'GetAccountDetailsEvent';
}
class AddAddressEvent extends AccountEvent {
  final List<Address> address;
  final String uid;
  final int defaultAddress;

  AddAddressEvent(this.address, this.uid, this.defaultAddress);

  @override
  String toString() => 'AddAddressEvent';
}

class EditAddressEvent extends AccountEvent {
  final List<Address> address;
  final String uid;
  final int defaultAddress;

  EditAddressEvent(this.address, this.uid, this.defaultAddress);

  @override
  String toString() => 'EditAddressEvent';
}

class RemoveAddressEvent extends AccountEvent {
  final List<Address> address;
  final String uid;
  final bool isDefault;

  RemoveAddressEvent(this.address, this.uid, this.isDefault);

  @override
  String toString() => 'RemoveAddressEvent';
}

class UpdateAccountDetailsEvent extends AccountEvent {
  final GroceryUser user;
  final Uint8List? profileImage;

  UpdateAccountDetailsEvent({required this.user, this.profileImage});

  @override
  String toString() => 'UpdateAccountDetailsEvent';
}
class getAllConsultationsEvent extends AccountEvent {
  @override
  String toString() => 'getAllConsultationsEvent';
}
