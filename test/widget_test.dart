// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:newlane/core/di/injection_container.dart';
// import 'package:newlane/features/architecture/presentation/pages/architecture_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   testWidgets('renders architecture scaffold', (WidgetTester tester) async {
//     SharedPreferences.setMockInitialValues(<String, Object>{});
//     await InjectionContainer.instance.init();

//     await tester.pumpWidget(
//       MaterialApp(
//         home: BlocProvider(
//           create: (_) => InjectionContainer.instance.createArchitectureCubit(),
//           child: const ArchitecturePage(),
//         ),
//       ),
//     );
//     await tester.pump();

//     expect(
//       find.text('Production-ready Clean Architecture scaffold'),
//       findsOneWidget,
//     );
//     expect(find.text('Architecture layers'), findsOneWidget);
//   });
// }
