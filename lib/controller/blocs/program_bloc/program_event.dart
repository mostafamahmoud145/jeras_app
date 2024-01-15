part of 'program_bloc.dart';

@immutable
abstract class ProgramEvent {}

class ProgramCompleted extends ProgramEvent
{
  String? programType;
  String  lang;
  ProgramCompleted({this.programType, required this.lang});
}
class AllProgramCompleted extends ProgramEvent
{
  AllProgramCompleted();
}

class getAllCoursesInProgramEvent extends ProgramEvent
{
  String programId;
  getAllCoursesInProgramEvent(this.programId);
}

class getAllConsultsInCourseEvent extends ProgramEvent
{
  String courseId;
  getAllConsultsInCourseEvent(this.courseId);
}