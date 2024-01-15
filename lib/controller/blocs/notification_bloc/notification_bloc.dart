
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:jeras/blocs/user_chat/user_chat.dart';
import 'package:meta/meta.dart';

import '../../../models/user_notification.dart';
import '../../../repositories/user_data_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final UserDataRepository userDataRepository;
  StreamSubscription? notificationSubscription;

  NotificationBloc({required this.userDataRepository}) : super( NotificationInitial()){
    on<GetAllNotificationsEvent>((event, emit) async {
      emit( GetAllNotificationsInProgressState());
      UserChat().updateReceivedMessagesForUser();
      try {
        notificationSubscription?.cancel();
        notificationSubscription =
            userDataRepository.getNotifications(event.uid)?.listen(
                  (notification) {

                add(NotificationUpdateEvent(notification));
              },
              onError: (err) {
                emit( GetAllNotificationsFailedState());
              },
            );
      } catch (e) {
        emit( GetAllNotificationsFailedState());
      }
    });
    //---------------------
    on<NotificationUpdateEvent>((event, emit) async {
      emit( GetNotificationsUpdateState(event.userNotification));
    });
    //---------------------
    on<NotificationMarkReadEvent>((event, emit) async {
      emit( NotificationMarkReadInProgressState());
      try {
        await userDataRepository.markNotificationRead(event.uid);
        emit( NotificationMarkReadCompletedState());
      } catch (e) {
        emit( NotificationMarkReadFailedState());
      }
    });
  }

  @override
  NotificationState get initialState => NotificationInitial();

  @override
  Future<void> close() {
    notificationSubscription?.cancel();
    return super.close();
  }

/*  @override
  Stream<NotificationState> mapEventToState(
    NotificationEvent event,
  ) async* {
    if (event is GetAllNotificationsEvent) {
      yield* mapGetAllNotificationsEventToState(event.uid);
    }
    if (event is NotificationUpdateEvent) {
      yield* mapNotificationUpdateEventToState(event.userNotification);
    }
    if (event is NotificationMarkReadEvent) {
      yield* mapNotificationMarkReadEventToState(event.uid);
    }
  }

  Stream<NotificationState> mapGetAllNotificationsEventToState(
      String uid) async* {
    yield GetAllNotificationsInProgressState();
    try {
      notificationSubscription?.cancel();
      notificationSubscription =
          userDataRepository.getNotifications(uid)?.listen(
        (notification) {

          add(NotificationUpdateEvent(notification));
        },
        onError: (err) {
          return GetAllNotificationsFailedState();
        },
      );
    } catch (e) {
      yield GetAllNotificationsFailedState();
    }
  }
 
  Stream<NotificationState> mapNotificationUpdateEventToState(
      UserNotification userNotification) async* {
    yield GetNotificationsUpdateState(userNotification);
  }

  Stream<NotificationState> mapNotificationMarkReadEventToState(
      String uid) async* {
    yield NotificationMarkReadInProgressState();
    try {
      await userDataRepository.markNotificationRead(uid);
      yield NotificationMarkReadCompletedState();
    } catch (e) {
      yield NotificationMarkReadFailedState();
    }
  }*/
}
