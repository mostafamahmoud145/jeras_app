part of 'program_bloc.dart';

@immutable
abstract class ProgramState {}

class ProgramInitial extends ProgramState {}

class ProgramLoading extends ProgramState {}

class ProgramCompletedState extends ProgramState {
  final List<Program> programs;
  ProgramCompletedState(this.programs);
}

class getAllCoursesInProgramState extends ProgramState {
  final List<Courses> allCourses;
  getAllCoursesInProgramState(this.allCourses);
}

class getAllConsultsInCourseState extends ProgramState {
  final List<GroceryUser> allConsults;
  getAllConsultsInCourseState(this.allConsults);
}


class ProgramErrorState extends ProgramState
{

}