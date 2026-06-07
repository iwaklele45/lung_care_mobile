import 'package:mocktail/mocktail.dart';
import 'package:lung_care_mobile/src/data/datasource/check_in_remote_data_source.dart';
import 'package:lung_care_mobile/src/data/datasource/dose_check_in_data_source.dart';
import 'package:lung_care_mobile/src/data/datasource/schedule_remote_data_source.dart';

class MockCheckInRemoteDataSource extends Mock
    implements CheckInRemoteDataSource {}

class MockDoseCheckInDataSource extends Mock
    implements DoseCheckInDataSource {}

class MockScheduleRemoteDataSource extends Mock
    implements ScheduleRemoteDataSource {}
