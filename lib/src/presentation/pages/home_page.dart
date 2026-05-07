import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lung_care_mobile/src/presentation/bloc/home/home_bloc.dart';
import 'package:lung_care_mobile/src/presentation/pages/home/home_body_view.dart';

/// Entry point for the Home feature.
///
/// Provides [HomeBloc] and immediately fetches today's schedules on creation.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => HomeBloc()..add(HomeFetchSchedulesRequested()),
      child: const HomeBodyView(),
    );
  }
}
