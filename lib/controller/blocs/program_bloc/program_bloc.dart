

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jeras/models/courses.dart';
import 'package:meta/meta.dart';

import '../../../models/program.dart';
import '../../../models/user.dart';

part 'program_event.dart';
part 'program_state.dart';

class ProgramBloc extends Bloc<ProgramEvent, ProgramState> {
  ProgramBloc() : super(ProgramInitial()) {
    on<ProgramEvent>((event, emit) async {
      emit (ProgramLoading());
    });
    on<ProgramCompleted>((event, emit) async {
      QuerySnapshot querySnapshot;
      try
      {
        List<Program> programs;
        if(event.programType == null)
          {
            querySnapshot = await FirebaseFirestore.instance
                .collection('Program')
                //.where("lang", isEqualTo: event.lang)
                //.where("active",isEqualTo: true )
                .get();
          }
        else
          {
             querySnapshot = await FirebaseFirestore.instance
                .collection('Program')
                .where("consultType", isEqualTo: event.programType)
                .where("active",isEqualTo: true )
                .where("lang", isEqualTo: event.lang)
                .get();
          }

        var allPrograms = List<Program>.from(
          querySnapshot.docs.map((snapshot) => Program.fromMap(snapshot.data() as Map),),
        );
        programs = allPrograms;
        emit(ProgramCompletedState(programs));
      }
      catch(e)
      {
        emit(ProgramErrorState());
      }
    });
    on<getAllCoursesInProgramEvent>((event, emit) async {
      try
      {
        List<Courses> courses;
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Courses').where("programId", isEqualTo: event.programId).get();

        var allCourses = List<Courses>.from(
          querySnapshot.docs.map((snapshot) => Courses.fromMap(snapshot.data() as Map),),
        );
        courses = allCourses;

        emit(getAllCoursesInProgramState(courses));
      }
      catch(e)
      {
        emit(ProgramErrorState());
      }
    });

    on<getAllConsultsInCourseEvent>((event, emit) async {
      try
      {
        List<GroceryUser> consults;
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Users').where('userType', isEqualTo: "CONSULTANT")
            .where('accountStatus', isEqualTo: "Active").where('courses', arrayContains: event.courseId).get();

        var allConsults = List<GroceryUser>.from(
          querySnapshot.docs.map((snapshot) => GroceryUser.fromMap(snapshot.data() as Map),),
        );
        consults = allConsults;

        emit(getAllConsultsInCourseState(consults));
      }
      catch(e)
      {
        emit(ProgramErrorState());
      }
    });
  }
}
