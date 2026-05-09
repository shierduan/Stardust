import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/providers/providers.dart';
import 'core/services/services.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.cardDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storageService = StorageService();
  await storageService.init();

  final appConfig = await storageService.loadAppConfig();
  final nuwaState = await storageService.loadNuwaState();
  final companionConfig = await storageService.loadCompanionConfig();
  final messages = await storageService.loadMessages();

  runApp(
    NuwaCompanionApp(
      storageService: storageService,
      initialConfig: appConfig,
      initialState: nuwaState,
      initialCompanionConfig: companionConfig,
      initialMessages: messages,
    ),
  );
}

class NuwaCompanionApp extends StatelessWidget {
  final StorageService storageService;
  final AppConfig initialConfig;
  final NuwaState? initialState;
  final CompanionConfig initialCompanionConfig;
  final List<ChatMessage> initialMessages;

  const NuwaCompanionApp({
    super.key,
    required this.storageService,
    required this.initialConfig,
    this.initialState,
    required this.initialCompanionConfig,
    required this.initialMessages,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = AppConfigProvider();
            provider.updateConfig(initialConfig);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = NuwaProvider();
            if (initialState != null) {
              provider.updateState(initialState!);
            }
            provider.updateConfig(initialCompanionConfig);
            for (var message in initialMessages) {
              provider.addMessage(message);
            }
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Nuwa Companion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
