import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jeras/models/courses.dart';
import 'package:meta/meta.dart';

import '../../../config/paths.dart';
import '../../../models/consultPackage.dart';
import '../../../models/consultReview.dart';
import '../../../models/setting.dart';
import '../../../models/user.dart';
import '../../../repositories/user_data_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final UserDataRepository userDataRepository;

  GroceryUser loggeduser = GroceryUser();

  AccountBloc({required this.userDataRepository}) : super(AccountInitial()) {
    on<GetLoggedUserEvent>((event, emit) async {
      emit(GetLoggedUserInProgressState());
      try {
        if (FirebaseAuth.instance.currentUser != null) {
          var ref = FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .withConverter(
                fromFirestore: GroceryUser.fromFirestore,
                toFirestore: (GroceryUser user, _) => user.toFirestore(),
              );
          final docSnap = await ref.get();
          GroceryUser? user = docSnap.data();
          if (user != null) {
            loggeduser = user;
            emit(GetLoggedUserCompletedState(user));
          } else {
            emit(GetLoggedUserFailedState());
          }
        } else {
          emit(GetLoggedUserFailedState());
        }
      } catch (e) {
        emit(GetLoggedUserFailedState());
      }
    });

    on<GetAccountDetailsEvent>((event, emit) async {
      try {
        GroceryUser? user = await userDataRepository.getUserDetails(event.uid);
        GroceryUser? consult =
            await userDataRepository.getConsultDetails(event.ConsultId);

        emit(GetAccountCompletedState(user!, consult!));
      } catch (e) {
        emit(GetLoggedUserFailedState());
      }
    });

    /*   on<GetAccountDetailsEvent>((event, emit) async {
      emit (GetAccountDetailsInProgressState());
      try {
          var ref = FirebaseFirestore.instance.collection(Paths.usersPath).doc(event.uid).withConverter(
            fromFirestore: GroceryUser.fromFirestore,
            toFirestore: (GroceryUser user, _) => user.toFirestore(), );
          final docSnap = await ref.get();
          GroceryUser? user = docSnap.data();
          if (user != null) {
            emit( GetAccountDetailsCompletedState(user));
          }
          else {
            emit( GetAccountDetailsFailedState());
          }
      } catch (e) {
        emit( GetAccountDetailsFailedState());
      }
    });*/
    //=========
    on<UpdateAccountDetailsEvent>((event, emit) async {
      emit(UpdateAccountDetailsInProgressState());
      try {
        bool isUpdated = await userDataRepository.updateAccountDetails(
            event.user, event.profileImage);
        if (isUpdated) {
          emit(UpdateAccountDetailsCompletedState());
        } else {
          emit(UpdateAccountDetailsFailedState());
        }
      } catch (e) {
        emit(UpdateAccountDetailsFailedState());
      }
    });

    on<GetConsultInfoEvent>((event, emit) async {
      emit(getConsultantInfoProgressState());
      GroceryUser? user;
      if (FirebaseAuth.instance.currentUser != null) {
        var ref = FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .withConverter(
              fromFirestore: GroceryUser.fromFirestore,
              toFirestore: (GroceryUser user, _) => user.toFirestore(),
            );
        final docSnap = await ref.get();
        user = docSnap.data();
      }

      try {
        GroceryUser? consultant =
            await userDataRepository.getAccountDetails(event.uid);
        if (consultant != null && user != null) {
          emit(getConsultantInfoCompletedState(
              consultant: consultant, user: user));
        } else if (consultant != null && user == null) {
          emit(getConsultantInfoCompletedState(
              consultant: consultant, user: user));
        } else {
          emit(getConsultantInfoFailedState());
        }
      } catch (e) {
        emit(getConsultantInfoFailedState());
      }
    });
    on<GetCourseDetailsEvent>((event, emit) async {
      emit(getCourseDetailsProgressState());
      GroceryUser? user;
      if (FirebaseAuth.instance.currentUser != null) {
        var ref = FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .withConverter(
              fromFirestore: GroceryUser.fromFirestore,
              toFirestore: (GroceryUser user, _) => user.toFirestore(),
            );
        final docSnap = await ref.get();
        user = docSnap.data();
      }
      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Courses")
            .doc(event.courseId)
            .get();

        Courses? course = Courses.fromMap(documentSnapshot.data() as Map);
        if (course != null) {
          emit(getCourseDetailsCompletedState(course: course, user: user));
        } else {
          emit(getCourseDetailsFailedState());
        }
      } catch (e) {
        emit(getCourseDetailsFailedState());
      }
    });
  }

  @override
  AccountState get initialState => AccountInitial();

  /*@override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is GetAccountDetailsEvent) {
      yield* mapGetAccountDetailsEventToState(
        uid: event.uid,
      );
    }
    if (event is GetConsultPackagesEvent) {
      yield* mapGetConsultPackagesEventToState(
        uid: event.uid,
      );
    }
    if (event is GetConsultReviewsEvent) {
      yield* mapGetConsultReviewsEventToState(
        uid: event.uid,
      );
    }
    if (event is UpdateAccountDetailsEvent) {
      yield* mapUpdateAccountDetailsEventToState(
        user: event.user,
        profileImage: event.profileImage,
      );
    }
  }*/

  Stream<AccountState> mapGetConsultPackagesEventToState(
      {required String uid}) async* {
    yield getConsultPackagesInProgressState();
    try {
      List<consultPackage>? packages =
          await userDataRepository.getConsultPackages(uid);
      if (packages != null) {
        yield getConsultPackagesCompletedState(packages);
      } else {
        yield getConsultPackagesFailedState();
      }
    } catch (e) {
      yield getConsultPackagesFailedState();
    }
  }

  Stream<AccountState> mapGetConsultInfoEventToState(
      {required String uid}) async* {
    yield getConsultantInfoProgressState();

    GroceryUser? user;
    if (FirebaseAuth.instance.currentUser != null) {
      var ref = FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .withConverter(
            fromFirestore: GroceryUser.fromFirestore,
            toFirestore: (GroceryUser user, _) => user.toFirestore(),
          );
      final docSnap = await ref.get();
      user = docSnap.data();
    }

    try {
      GroceryUser? consltant = await userDataRepository.getAccountDetails(uid);
      if (consltant != null && user != null) {
        yield (getConsultantInfoCompletedState(
            consultant: consltant, user: user));
      } else if (consltant != null && user == null) {
        yield (getConsultantInfoCompletedState(
            consultant: consltant, user: user));
      } else {
        yield getConsultantInfoFailedState();
      }
    } catch (e) {
      yield getConsultantInfoFailedState();
    }
  }

  Stream<AccountState> mapGetConsultReviewsEventToState(
      {required String uid}) async* {
    yield getConsultReviewsInProgressState();
    try {
      List<ConsultReview>? reviews =
          await userDataRepository.getConsultReviewes(uid);
      if (reviews != null) {
        yield getConsultReviewsCompletedState(reviews);
      } else {
        yield getConsultReviewsFailedState();
      }
    } catch (e) {
      yield getConsultReviewsFailedState();
    }
  }

  Stream<AccountState> mapGetAccountDetailsEventToState(
      {required String uid}) async* {
    yield GetAccountDetailsInProgressState();
    try {
      GroceryUser? user = await userDataRepository.getAccountDetails(uid);
      if (user != null) {
        yield GetAccountDetailsCompletedState(user);
      } else {
        yield GetAccountDetailsFailedState();
      }
    } catch (e) {
      yield GetAccountDetailsFailedState();
    }
  }

  Stream<AccountState> mapUpdateAccountDetailsEventToState(
      {required GroceryUser user, Uint8List? profileImage}) async* {
    yield UpdateAccountDetailsInProgressState();
    try {
      bool isUpdated =
          await userDataRepository.updateAccountDetails(user, profileImage);
      if (isUpdated) {
        yield UpdateAccountDetailsCompletedState();
      } else {
        yield UpdateAccountDetailsFailedState();
      }
    } catch (e) {
      yield UpdateAccountDetailsFailedState();
    }
  }
}
