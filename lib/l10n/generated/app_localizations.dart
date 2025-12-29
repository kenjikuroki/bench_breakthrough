import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BENCH BREAKTHROUGH'**
  String get appTitle;

  /// No description provided for @historyAnalysis.
  ///
  /// In en, this message translates to:
  /// **'HISTORY / ANALYSIS'**
  String get historyAnalysis;

  /// No description provided for @maxWeight.
  ///
  /// In en, this message translates to:
  /// **'MAX WEIGHT'**
  String get maxWeight;

  /// No description provided for @workoutHistory.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT HISTORY'**
  String get workoutHistory;

  /// No description provided for @showList.
  ///
  /// In en, this message translates to:
  /// **'Show List'**
  String get showList;

  /// No description provided for @showChart.
  ///
  /// In en, this message translates to:
  /// **'Show Chart'**
  String get showChart;

  /// No description provided for @showDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get showDiagnosis;

  /// No description provided for @diagnosisTitle.
  ///
  /// In en, this message translates to:
  /// **'DIAGNOSIS'**
  String get diagnosisTitle;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'START WORKOUT'**
  String get startWorkout;

  /// No description provided for @todaysMission.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S MISSION'**
  String get todaysMission;

  /// No description provided for @limitBreak.
  ///
  /// In en, this message translates to:
  /// **'LIMIT BREAK!'**
  String get limitBreak;

  /// No description provided for @limitBreakMsg.
  ///
  /// In en, this message translates to:
  /// **'EXCEEDED!'**
  String get limitBreakMsg;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @premiumBody.
  ///
  /// In en, this message translates to:
  /// **'To use this feature, you need to subscribe to Premium.\n\nCheck your growth trajectory with the estimated 1RM graph!'**
  String get premiumBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @premiumSuccess.
  ///
  /// In en, this message translates to:
  /// **'You are now a Premium member!'**
  String get premiumSuccess;

  /// No description provided for @premiumOnly.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM ONLY'**
  String get premiumOnly;

  /// No description provided for @logWorkout.
  ///
  /// In en, this message translates to:
  /// **'LOG WORKOUT'**
  String get logWorkout;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get finish;

  /// No description provided for @estimated1rm.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED 1RM'**
  String get estimated1rm;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get weight;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get reps;

  /// No description provided for @saveSet.
  ///
  /// In en, this message translates to:
  /// **'SAVE SET'**
  String get saveSet;

  /// No description provided for @todaysSets.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S SETS'**
  String get todaysSets;

  /// No description provided for @noSetsYet.
  ///
  /// In en, this message translates to:
  /// **'No sets yet'**
  String get noSetsYet;

  /// No description provided for @setDeleted.
  ///
  /// In en, this message translates to:
  /// **'Set deleted'**
  String get setDeleted;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @usePounds.
  ///
  /// In en, this message translates to:
  /// **'Use Pounds (lbs)'**
  String get usePounds;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @membership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membership;

  /// No description provided for @proMember.
  ///
  /// In en, this message translates to:
  /// **'PRO Member'**
  String get proMember;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @motivation1.
  ///
  /// In en, this message translates to:
  /// **'Why worry? Just lift it.'**
  String get motivation1;

  /// No description provided for @motivation2.
  ///
  /// In en, this message translates to:
  /// **'Stop talking. Load the plates.'**
  String get motivation2;

  /// No description provided for @motivation3.
  ///
  /// In en, this message translates to:
  /// **'Heavy? So what.'**
  String get motivation3;

  /// No description provided for @motivation4.
  ///
  /// In en, this message translates to:
  /// **'You gonna lose to a piece of iron?'**
  String get motivation4;

  /// No description provided for @motivation5.
  ///
  /// In en, this message translates to:
  /// **'Complaint after you lift.'**
  String get motivation5;

  /// No description provided for @motivation6.
  ///
  /// In en, this message translates to:
  /// **'Don\'t argue. Lift and you\'ll see.'**
  String get motivation6;

  /// No description provided for @motivation7.
  ///
  /// In en, this message translates to:
  /// **'Rest today, weak forever.'**
  String get motivation7;

  /// No description provided for @motivation8.
  ///
  /// In en, this message translates to:
  /// **'No one will help. You lift it.'**
  String get motivation8;

  /// No description provided for @motivation9.
  ///
  /// In en, this message translates to:
  /// **'Fear? Crush it with the barbell.'**
  String get motivation9;

  /// No description provided for @motivation10.
  ///
  /// In en, this message translates to:
  /// **'Leave your weakness on the bench.'**
  String get motivation10;

  /// No description provided for @motivation11.
  ///
  /// In en, this message translates to:
  /// **'Do or do not? There is only do.'**
  String get motivation11;

  /// No description provided for @motivation12.
  ///
  /// In en, this message translates to:
  /// **'Limit? That\'s a hallucination.'**
  String get motivation12;

  /// No description provided for @motivation13.
  ///
  /// In en, this message translates to:
  /// **'Grind your teeth. Miracles don\'t happen.'**
  String get motivation13;

  /// No description provided for @motivation14.
  ///
  /// In en, this message translates to:
  /// **'Press like you breathe.'**
  String get motivation14;

  /// No description provided for @motivation15.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t your limit.'**
  String get motivation15;

  /// No description provided for @motivation16.
  ///
  /// In en, this message translates to:
  /// **'Clear your mind. Lock out.'**
  String get motivation16;

  /// No description provided for @motivation17.
  ///
  /// In en, this message translates to:
  /// **'Losing to yesterday\'s you? Shame.'**
  String get motivation17;

  /// No description provided for @motivation18.
  ///
  /// In en, this message translates to:
  /// **'Relax. Muscles don\'t betray.'**
  String get motivation18;

  /// No description provided for @motivation19.
  ///
  /// In en, this message translates to:
  /// **'Don\'t be satisfied. Not enough.'**
  String get motivation19;

  /// No description provided for @motivation20.
  ///
  /// In en, this message translates to:
  /// **'Taste the iron.'**
  String get motivation20;

  /// No description provided for @motivation21.
  ///
  /// In en, this message translates to:
  /// **'Lift like you\'ll die. You won\'t.'**
  String get motivation21;

  /// No description provided for @zoneTitleReckless.
  ///
  /// In en, this message translates to:
  /// **'ZONE A: RECKLESS'**
  String get zoneTitleReckless;

  /// No description provided for @zoneTitleChallenge.
  ///
  /// In en, this message translates to:
  /// **'ZONE B: CHALLENGE'**
  String get zoneTitleChallenge;

  /// No description provided for @zoneTitleClose.
  ///
  /// In en, this message translates to:
  /// **'ZONE C: CLOSE CALL'**
  String get zoneTitleClose;

  /// No description provided for @zoneTitleStagnation.
  ///
  /// In en, this message translates to:
  /// **'ZONE D: STAGNATION'**
  String get zoneTitleStagnation;

  /// No description provided for @zoneTitleSlump.
  ///
  /// In en, this message translates to:
  /// **'ZONE E: SLUMP'**
  String get zoneTitleSlump;

  /// No description provided for @labelFailedWeight.
  ///
  /// In en, this message translates to:
  /// **'FAILED WEIGHT'**
  String get labelFailedWeight;

  /// No description provided for @labelFailedPosition.
  ///
  /// In en, this message translates to:
  /// **'FAILED POSITION'**
  String get labelFailedPosition;

  /// No description provided for @labelBottom.
  ///
  /// In en, this message translates to:
  /// **'BOTTOM'**
  String get labelBottom;

  /// No description provided for @labelMiddle.
  ///
  /// In en, this message translates to:
  /// **'MIDDLE'**
  String get labelMiddle;

  /// No description provided for @labelTop.
  ///
  /// In en, this message translates to:
  /// **'TOP'**
  String get labelTop;

  /// No description provided for @labelBottomJp.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get labelBottomJp;

  /// No description provided for @labelMiddleJp.
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get labelMiddleJp;

  /// No description provided for @labelTopJp.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get labelTopJp;

  /// No description provided for @btnAnalyze.
  ///
  /// In en, this message translates to:
  /// **'ANALYZE'**
  String get btnAnalyze;

  /// No description provided for @msgInputError.
  ///
  /// In en, this message translates to:
  /// **'Enter weight and failed position. Don\'t be lazy.'**
  String get msgInputError;

  /// No description provided for @msgDataError.
  ///
  /// In en, this message translates to:
  /// **'Data error.'**
  String get msgDataError;

  /// No description provided for @diagnosisIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'WEAKNESS FINDER'**
  String get diagnosisIntroTitle;

  /// No description provided for @diagnosisIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze failure, expose weakness'**
  String get diagnosisIntroSubtitle;

  /// No description provided for @btnBackToTraining.
  ///
  /// In en, this message translates to:
  /// **'Close and Return to Training'**
  String get btnBackToTraining;

  /// No description provided for @diagnosisRecklessBottom1.
  ///
  /// In en, this message translates to:
  /// **'Your weight setting doesn\'t match your current form. To prevent injury, I recommend lowering the weight and ensuring control at the bottom before trying again.'**
  String get diagnosisRecklessBottom1;

  /// No description provided for @diagnosisRecklessBottom2.
  ///
  /// In en, this message translates to:
  /// **'You might not be able to catch the weight. The shortcut is to find the limit where you can maintain correct form with lighter weight to promote neurological adaptation.'**
  String get diagnosisRecklessBottom2;

  /// No description provided for @diagnosisRecklessBottom3.
  ///
  /// In en, this message translates to:
  /// **'Excessive heavy weight leads to form breakdown. First, return to a weight you can handle and train to improve stability in the starting position.'**
  String get diagnosisRecklessBottom3;

  /// No description provided for @diagnosisRecklessMiddle1.
  ///
  /// In en, this message translates to:
  /// **'If you try to lift with momentum, it puts stress on your joints at the midpoint. Return to a controllable weight setting and focus on careful strokes.'**
  String get diagnosisRecklessMiddle1;

  /// No description provided for @diagnosisRecklessMiddle2.
  ///
  /// In en, this message translates to:
  /// **'Control at this weight might be premature. Prioritize stabilizing the trajectory by lowering the weight, as the risk of injury increases.'**
  String get diagnosisRecklessMiddle2;

  /// No description provided for @diagnosisRecklessMiddle3.
  ///
  /// In en, this message translates to:
  /// **'There is a fear that form cannot be maintained. Until you build basic strength, avoid challenging impossible weights and strive to learn the correct trajectory.'**
  String get diagnosisRecklessMiddle3;

  /// No description provided for @diagnosisRecklessTop1.
  ///
  /// In en, this message translates to:
  /// **'It seems you lack the strength to push through to the finish. Forcing it may hurt your joints, so cultivate basic triceps strength with accessory exercises.'**
  String get diagnosisRecklessTop1;

  /// No description provided for @diagnosisRecklessTop2.
  ///
  /// In en, this message translates to:
  /// **'If trunk instability is seen, it\'s a sign of overweight. First lower the weight and prioritize building a foundation that doesn\'t wobble at the finish.'**
  String get diagnosisRecklessTop2;

  /// No description provided for @diagnosisRecklessTop3.
  ///
  /// In en, this message translates to:
  /// **'Have the courage to lower the weight if your form collapses even slightly. Completing with correct form is the shortest route to growth.'**
  String get diagnosisRecklessTop3;

  /// No description provided for @diagnosisChallengeBottom1.
  ///
  /// In en, this message translates to:
  /// **'Initial output shortage is possible. To improve explosiveness, incorporating \'Pause Bench\' with lighter weight is generally effective.'**
  String get diagnosisChallengeBottom1;

  /// No description provided for @diagnosisChallengeBottom2.
  ///
  /// In en, this message translates to:
  /// **'Be conscious of stretching the pectoralis major. Trying a slightly wider grip within a comfortable range of motion is also one way to strengthen the bottom.'**
  String get diagnosisChallengeBottom2;

  /// No description provided for @diagnosisChallengeBottom3.
  ///
  /// In en, this message translates to:
  /// **'You may not be using lower body power. Be conscious of firmly planting your feet when lowering the bar and improving whole-body coordination.'**
  String get diagnosisChallengeBottom3;

  /// No description provided for @diagnosisChallengeMiddle1.
  ///
  /// In en, this message translates to:
  /// **'Weakness in reversal might be the issue. Consider introducing \'Spoto Press\', stopping a few centimeters above the chest, to strengthen the sticking point.'**
  String get diagnosisChallengeMiddle1;

  /// No description provided for @diagnosisChallengeMiddle2.
  ///
  /// In en, this message translates to:
  /// **'Load transfer might not be smooth. It effective to intensively strengthen muscle output at the midpoint with limited range of motion exercises like \'Floor Press\'.'**
  String get diagnosisChallengeMiddle2;

  /// No description provided for @diagnosisChallengeMiddle3.
  ///
  /// In en, this message translates to:
  /// **'Bar acceleration may be insufficient. Try lifting with speed, keeping an image of pushing up all at once from bottom to top.'**
  String get diagnosisChallengeMiddle3;

  /// No description provided for @diagnosisChallengeTop1.
  ///
  /// In en, this message translates to:
  /// **'Lockout reinforcement is necessary. I recommend adding \'Close Grip Bench\' at the end of your set to intensively train triceps.'**
  String get diagnosisChallengeTop1;

  /// No description provided for @diagnosisChallengeTop2.
  ///
  /// In en, this message translates to:
  /// **'Power might be escaping at the finish. Being conscious of pulling the bar outward helps tighten the armpits and increase stimulation to the triceps.'**
  String get diagnosisChallengeTop2;

  /// No description provided for @diagnosisChallengeTop3.
  ///
  /// In en, this message translates to:
  /// **'As neurological reinforcement in the final phase, limited range of motion exercises like \'Board Press\' may be effective. Try it in a safe environment.'**
  String get diagnosisChallengeTop3;

  /// No description provided for @diagnosisCloseBottom1.
  ///
  /// In en, this message translates to:
  /// **'Review your setup. If scapular retraction is weak, the bottom becomes unstable. Reconfirm your back arch before rack up.'**
  String get diagnosisCloseBottom1;

  /// No description provided for @diagnosisCloseBottom2.
  ///
  /// In en, this message translates to:
  /// **'Breathing timing might be off. Be conscious of applying abdominal pressure (bracing) firmly and solidifying your trunk before starting the movement.'**
  String get diagnosisCloseBottom2;

  /// No description provided for @diagnosisCloseBottom3.
  ///
  /// In en, this message translates to:
  /// **'Mental influence is also possible. Don\'t be too conscious of clear heaviness, focus on lifting with your usual rhythm.'**
  String get diagnosisCloseBottom3;

  /// No description provided for @diagnosisCloseMiddle1.
  ///
  /// In en, this message translates to:
  /// **'Force tends to disperse if elbows open. Correct the trajectory so elbows come directly under the bar by tightening armpits moderately.'**
  String get diagnosisCloseMiddle1;

  /// No description provided for @diagnosisCloseMiddle2.
  ///
  /// In en, this message translates to:
  /// **'Check if the bar trajectory is flowing towards your face. Always keep careful movement in mind, tracing a vertical or appropriate trajectory.'**
  String get diagnosisCloseMiddle2;

  /// No description provided for @diagnosisCloseMiddle3.
  ///
  /// In en, this message translates to:
  /// **'If your gaze wavers, your form wavers. Staring at one point on the ceiling and fixing your head position often increases lifting stability.'**
  String get diagnosisCloseMiddle3;

  /// No description provided for @diagnosisCloseTop1.
  ///
  /// In en, this message translates to:
  /// **'Bent wrists cause power loss. Reconfirm grip strength and angle with the image of placing the bar on the forearm bones.'**
  String get diagnosisCloseTop1;

  /// No description provided for @diagnosisCloseTop2.
  ///
  /// In en, this message translates to:
  /// **'Hold strong consciousness towards the finish. Don\'t relax until lift completion, image training of pushing through to the end is effective.'**
  String get diagnosisCloseTop2;

  /// No description provided for @diagnosisCloseTop3.
  ///
  /// In en, this message translates to:
  /// **'If hips float, power escapes and causes fouls or back pain. Capture the floor with whole soles and keep glutes attached to the bench.'**
  String get diagnosisCloseTop3;

  /// No description provided for @diagnosisStagnationBottom1.
  ///
  /// In en, this message translates to:
  /// **'Negative motion (lowering movement) might be sloppy. Keep consciousness of lowering with control while maintaining muscle tension.'**
  String get diagnosisStagnationBottom1;

  /// No description provided for @diagnosisStagnationBottom2.
  ///
  /// In en, this message translates to:
  /// **'Start position might be collapsing. Perform setup carefully every time and repeat so you can always start with the same form.'**
  String get diagnosisStagnationBottom2;

  /// No description provided for @diagnosisStagnationBottom3.
  ///
  /// In en, this message translates to:
  /// **'Lack of concentration is the source of injury. Before entering a set, regulate breathing and prepare to face the barbell.'**
  String get diagnosisStagnationBottom3;

  /// No description provided for @diagnosisStagnationMiddle1.
  ///
  /// In en, this message translates to:
  /// **'Habit of relying on recoil might be attached. Practicing with a \'pause\' is also a good means to cultivate the sensation of lifting with muscle power.'**
  String get diagnosisStagnationMiddle1;

  /// No description provided for @diagnosisStagnationMiddle2.
  ///
  /// In en, this message translates to:
  /// **'Check if shoulders are shrugged. Keeping shoulders down (depression) and chest up is indispensable for smooth lifting.'**
  String get diagnosisStagnationMiddle2;

  /// No description provided for @diagnosisStagnationMiddle3.
  ///
  /// In en, this message translates to:
  /// **'Consciousness towards lifting speed might be fading. Don\'t lose to weight, recall the \'aggressive feeling\' of pushing up proactively.'**
  String get diagnosisStagnationMiddle3;

  /// No description provided for @diagnosisStagnationTop1.
  ///
  /// In en, this message translates to:
  /// **'Left-right balance difference might be influencing. Adjusting left-right difference with Dumbbell Press helps break stagnation.'**
  String get diagnosisStagnationTop1;

  /// No description provided for @diagnosisStagnationTop2.
  ///
  /// In en, this message translates to:
  /// **'It might be stamina shortage to push through to the end. Perform triceps accessory exercises and raise basic endurance.'**
  String get diagnosisStagnationTop2;

  /// No description provided for @diagnosisStagnationTop3.
  ///
  /// In en, this message translates to:
  /// **'Giving up might be too early. Believing \'it will lift\' and continuing to put power until the end opens a neurological breakthrough.'**
  String get diagnosisStagnationTop3;

  /// No description provided for @diagnosisSlumpBottom1.
  ///
  /// In en, this message translates to:
  /// **'Fatigue might be accumulating. Continuing forcibly risks injury, so call it a day early and get sufficient sleep and nutrition.'**
  String get diagnosisSlumpBottom1;

  /// No description provided for @diagnosisSlumpBottom2.
  ///
  /// In en, this message translates to:
  /// **'If you feel body heaviness, condition adjustment is insufficient. Perform warm-up carefully or adjust with light weight until condition returns.'**
  String get diagnosisSlumpBottom2;

  /// No description provided for @diagnosisSlumpBottom3.
  ///
  /// In en, this message translates to:
  /// **'If the nervous system is exhausted, heavy weight can be counterproductive. Consider courageous rest as part of training.'**
  String get diagnosisSlumpBottom3;

  /// No description provided for @diagnosisSlumpMiddle1.
  ///
  /// In en, this message translates to:
  /// **'Any joint discomfort? If there is pain, I strongly recommend stopping training immediately and seeking professional diagnosis.'**
  String get diagnosisSlumpMiddle1;

  /// No description provided for @diagnosisSlumpMiddle2.
  ///
  /// In en, this message translates to:
  /// **'If form is collapsing, drop the weight significantly and return to form practice. Bad habits take time to fix.'**
  String get diagnosisSlumpMiddle2;

  /// No description provided for @diagnosisSlumpMiddle3.
  ///
  /// In en, this message translates to:
  /// **'Everyone has days where they can\'t concentrate. It\'s a wise choice to stop or change the menu to refresh before getting injured.'**
  String get diagnosisSlumpMiddle3;

  /// No description provided for @diagnosisSlumpTop1.
  ///
  /// In en, this message translates to:
  /// **'Might be a sign of overwork. Review recent training frequency and consider setting appropriate rest days.'**
  String get diagnosisSlumpTop1;

  /// No description provided for @diagnosisSlumpTop2.
  ///
  /// In en, this message translates to:
  /// **'Mental stress might be influencing. Prioritize refresh and wait for a day when you can face the barbell in perfect condition.'**
  String get diagnosisSlumpTop2;

  /// No description provided for @diagnosisSlumpTop3.
  ///
  /// In en, this message translates to:
  /// **'Power doesn\'t come out with energy shortage. Review lifestyle habits, like if pre-workout meal and hydration were appropriate.'**
  String get diagnosisSlumpTop3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
