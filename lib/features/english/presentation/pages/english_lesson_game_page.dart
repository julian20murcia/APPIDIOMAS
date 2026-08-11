import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../data/english_level_1_curriculum.dart';
import '../../data/english_level_1_games.dart';
import '../../models/english_lesson.dart';

class EnglishLessonGamePage extends StatefulWidget {
  final EnglishLesson lesson;
  const EnglishLessonGamePage({super.key, required this.lesson});

  @override
  State<EnglishLessonGamePage> createState() => _EnglishLessonGamePageState();
}

class _EnglishLessonGamePageState extends State<EnglishLessonGamePage>
    with SingleTickerProviderStateMixin {
  final _rng = math.Random();
  final _tts = FlutterTts();
  late final AnimationController _pulse;
  late final EnglishLessonGameConfig config;

  int round = 0;
  int score = 0;
  int streak = 0;
  bool answered = false;
  String? selected;
  bool? lastCorrect;
  double sliderValue = 0;
  List<String> options = const [];
  List<String> englishOptions = const [];
  List<String> tokens = const [];
  List<String> built = [];
  final Set<int> flipped = <int>{};

  List<dynamic> get vocab => englishLevel1Vocabulary[widget.lesson.number] ?? const [];
  dynamic get pair => vocab[round % vocab.length];

  @override
  void initState() {
    super.initState();
    config = englishLevel1Games[widget.lesson.number]!;
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 760))..repeat(reverse: true);
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.42);
    _prepareRound();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _tts.stop();
    super.dispose();
  }

  void _prepareRound() {
    if (vocab.isEmpty) return;
    final current = pair;
    final ds = vocab.where((e) => e.english != current.english).map((e) => e.english as String).toList()..shuffle(_rng);
    options = <String>[current.english as String, ...ds.take(3)]..shuffle(_rng);
    final eds = vocab.where((e) => e.english != current.english).map((e) => e.english as String).toList()..shuffle(_rng);
    englishOptions = <String>[current.english as String, ...eds.take(3)]..shuffle(_rng);
    final words = (current.english as String).replaceAll(RegExp(r"[^A-Za-z0-9' ]"), '').split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    tokens = List<String>.from(words)..shuffle(_rng);
    built = [];
    flipped.clear();
    sliderValue = 0;
    answered = false;
    selected = null;
    lastCorrect = null;
  }

  void _complete(bool correct, [String? value]) {
    if (answered) return;
    setState(() {
      answered = true;
      selected = value;
      lastCorrect = correct;
      if (correct) {
        score += 100 + streak * 20;
        streak += 1;
      } else {
        streak = 0;
      }
    });
  }

  void _answer(String value) => _complete(value == pair.english, value);

  int get totalRounds => vocab.isEmpty ? 1 : vocab.length;

  void _next() {
    if (round >= totalRounds - 1) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      round += 1;
      _prepareRound();
    });
  }

  Future<void> _speak([String? text]) async {
    await _tts.stop();
    await _tts.speak(text ?? pair.english as String);
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 760;
    return Scaffold(
      backgroundColor: const Color(0xFF07182A),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: ListView(
                  key: ValueKey('${config.mode}-$round-$answered'),
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(18, compact ? 10 : 16, 18, 30),
                  children: [
                    _hero(compact),
                    const SizedBox(height: 14),
                    _mechanic(compact),
                    if (answered) ...[
                      const SizedBox(height: 14),
                      _feedback(),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: config.accent,
                            foregroundColor: const Color(0xFF07111F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          icon: Icon(round >= totalRounds - 1 ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded),
                          label: Text(round >= totalRounds - 1 ? 'Terminar misión' : 'Siguiente ronda', style: const TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 16, 0),
        child: Row(
          children: [
            IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close_rounded, color: Colors.white70)),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: (round + 1) / totalRounds, minHeight: 8, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(config.accent)))),
            const SizedBox(width: 12),
            Text('$score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
      );

  Widget _hero(bool compact) => Container(
        padding: EdgeInsets.all(compact ? 16 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [config.accent.withOpacity(.22), const Color(0xFF10263D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: config.accent.withOpacity(.28)),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, child) => Transform.scale(scale: 1 + .045 * _pulse.value, child: child),
              child: Container(width: 58, height: 58, decoration: BoxDecoration(color: config.accent, borderRadius: BorderRadius.circular(19)), child: Icon(config.icon, color: const Color(0xFF07182A), size: 30)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(config.title, style: TextStyle(color: Colors.white, fontSize: compact ? 20 : 23, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(config.mission, style: const TextStyle(color: Colors.white60, fontSize: 12.7, height: 1.32)),
            ])),
            if (streak > 1) Text('🔥 $streak', style: TextStyle(color: config.accent, fontWeight: FontWeight.w900)),
          ],
        ),
      );

  Widget _mechanic(bool compact) {
    // Cada juego tiene una mecánica firma, pero las rondas alternan habilidades
    // para que no sea el mismo gesto repetido durante toda la lección.
    if (config.mode != EnglishGameMode.numberTap &&
        config.mode != EnglishGameMode.numberCode) {
      final phase = round % 3;
      if (phase == 1) return _listeningRound();
      if (phase == 2) {
        final wordCount = (pair.english as String).trim().split(RegExp(r'\s+')).length;
        return wordCount > 1 ? _wordForge() : _meaningDragRound();
      }
    }

    switch (config.mode) {
      case EnglishGameMode.greetingRush: return _conversationChoice('Una persona acaba de llegar. ¿Qué responderías?', Icons.chat_bubble_rounded);
      case EnglishGameMode.emotionRadar: return _emotionMeter();
      case EnglishGameMode.pronounSpotlight: return _spotlight();
      case EnglishGameMode.teamBuilder: return _teamBuilder();
      case EnglishGameMode.beForge: return _wordForge();
      case EnglishGameMode.identityDetective: return _detectiveCase();
      case EnglishGameMode.numberTap: return _numberPad();
      case EnglishGameMode.numberCode: return _codeLock();
      case EnglishGameMode.colorSplash: return _colorPalette();
      case EnglishGameMode.familyTree: return _familyTree();
      case EnglishGameMode.articleGate: return _twoGates();
      case EnglishGameMode.inventoryRush: return _inventoryShelf();
      case EnglishGameMode.avatarBuilder: return _avatarBuilder();
      case EnglishGameMode.bodyScan: return _bodyScanner();
      case EnglishGameMode.clockRace: return _clockFace();
      case EnglishGameMode.sportsCoach: return _sportsBoard();
      case EnglishGameMode.comparisonClimb: return _climb();
      case EnglishGameMode.marketBasket: return _dragBins('COUNTABLE', 'UNCOUNTABLE');
      case EnglishGameMode.wishWheel: return _wishWheel();
      case EnglishGameMode.petCare: return _petCare();
      case EnglishGameMode.routineBuilder: return _timeline();
      case EnglishGameMode.passportRun: return _passport();
      case EnglishGameMode.breakfastCafe: return _cafeTray();
      case EnglishGameMode.fruitSlice: return _sliceBoard('🍎', '🍊', '🍓', '🍉');
      case EnglishGameMode.veggieGarden: return _garden();
      case EnglishGameMode.shoppingCart: return _shop();
      case EnglishGameMode.careerMatch: return _careerCards();
      case EnglishGameMode.americaTrip: return _travelMap();
      case EnglishGameMode.cityNavigator: return _cityGrid();
      case EnglishGameMode.roomDesigner: return _roomDesigner();
      case EnglishGameMode.actionCamera: return _cameraFrame();
      case EnglishGameMode.hideAndSeek: return _hideAndSeek();
      case EnglishGameMode.jobInterview: return _interview();
      case EnglishGameMode.ownershipLocker: return _lockers();
      case EnglishGameMode.sizeSorter: return _sizeSorter();
      case EnglishGameMode.calendarDash: return _calendar();
    }
  }

  Widget _listeningRound() => _panel(
        child: Column(
          children: [
            Text('LISTENING ROUND', style: TextStyle(color: config.accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 10),
            Text('Escucha sin mirar la respuesta y toca el significado correcto.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            InkWell(
              onTap: _speak,
              borderRadius: BorderRadius.circular(999),
              child: Container(width: 84, height: 84, decoration: BoxDecoration(shape: BoxShape.circle, color: config.accent.withOpacity(.16), border: Border.all(color: config.accent.withOpacity(.55))), child: Icon(Icons.volume_up_rounded, color: config.accent, size: 38)),
            ),
            const SizedBox(height: 18),
            _choiceGrid(),
          ],
        ),
      );

  Widget _meaningDragRound() => _panel(
        child: Column(
          children: [
            Text('MATCH ROUND', style: TextStyle(color: config.accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 10),
            Text('Arrastra “${pair.english}” hasta su significado.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Draggable<String>(
              data: pair.english as String,
              feedback: Material(color: Colors.transparent, child: _dragCard(pair.english as String)),
              childWhenDragging: Opacity(opacity: .25, child: _dragCard(pair.english as String)),
              child: _dragCard(pair.english as String),
            ),
            const SizedBox(height: 18),
            ...options.take(3).map((value) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DragTarget<String>(
                onAccept: (_) => _complete(value == pair.english, value),
                builder: (_, __, ___) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)), child: Text(value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
              ),
            )),
          ],
        ),
      );

  Widget _panel({required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.045), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(.08))),
        child: child,
      );

  Widget _titlePrompt(String text, {Widget? visual}) => Column(children: [
        Row(children: [Text('RONDA ${round + 1} DE $totalRounds', style: TextStyle(color: config.accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .7)), const Spacer(), Text('+${100 + streak * 20} pts', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 18),
        if (visual != null) visual,
        if (visual != null) const SizedBox(height: 14),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, height: 1.35)),
        const SizedBox(height: 8),
        Text(pair.english as String, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
      ]);

  Widget _choiceGrid() => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: options.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.75, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemBuilder: (_, i) {
          final value = options[i];
          final correct = value == pair.english;
          final chosen = selected == value;
          Color bg = Colors.white.withOpacity(.045), border = Colors.white12;
          if (answered && correct) { bg = const Color(0xFF3DDC97).withOpacity(.13); border = const Color(0xFF3DDC97); }
          if (answered && chosen && !correct) { bg = const Color(0xFFFF667A).withOpacity(.12); border = const Color(0xFFFF667A); }
          return InkWell(onTap: answered ? null : () => _answer(value), borderRadius: BorderRadius.circular(18), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)), alignment: Alignment.center, child: Text(value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))));
        },
      );

  Widget _conversationChoice(String prompt, IconData icon) => _panel(child: Column(children: [_titlePrompt(prompt, visual: Icon(icon, color: config.accent, size: 50)), const SizedBox(height: 18), _choiceGrid()]));

  Widget _emotionMeter() {
    String emojiFor(String value) {
      final v=value.toLowerCase();
      if(v.contains('happy')||v.contains('pleased')||v.contains('well')) return '😄';
      if(v.contains('tired')) return '😴'; if(v.contains('sad')||v.contains('disappointed')) return '😢';
      if(v.contains('nervous')||v.contains('worried')) return '😟'; if(v.contains('angry')||v.contains('fed up')) return '😠';
      if(v.contains('terrified')) return '😱'; if(v.contains('surprised')) return '😲'; if(v.contains('proud')) return '😌';
      if(v.contains('jealous')) return '😒'; if(v.contains('guilty')||v.contains('ashamed')) return '😳';
      if(v.contains('bored')) return '🥱'; return '💬';
    }
    return _panel(child: Column(children: [
      Text('EMOTION RADAR', style: TextStyle(color: config.accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
      const SizedBox(height: 8),
      Text(pair.english as String, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
      const SizedBox(height: 16),
      Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: englishOptions.map((value)=>InkWell(
        onTap: answered ? null : () => _complete(value == pair.english, value),
        borderRadius: BorderRadius.circular(20),
        child: Container(width: 128,height:102,padding:const EdgeInsets.all(8),alignment:Alignment.center,decoration:BoxDecoration(color:Colors.white.withOpacity(.045),borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.white12)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(emojiFor(value),style:const TextStyle(fontSize:35)),const SizedBox(height:5),Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w800))])),
      )).toList()),
    ]));
  }

  Widget _spotlight() {
    const pronouns = ['I','You','He','She','It'];
    final exactPronoun = pronouns.contains(pair.english as String);
    final values = exactPronoun ? pronouns : englishOptions;
    return _panel(child: Column(children:[
      Text('PRONOUN SPOTLIGHT',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
      const SizedBox(height:10), Text(pair.english as String,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w900)),
      const SizedBox(height:16), Container(height:105,decoration:BoxDecoration(gradient:RadialGradient(colors:[config.accent.withOpacity(.35),Colors.transparent])),child:const Center(child:Icon(Icons.person_rounded,color:Colors.white,size:66))),
      const SizedBox(height:12), Wrap(spacing:9,runSpacing:9,alignment:WrapAlignment.center,children:values.map((v)=>ActionChip(backgroundColor:config.accent.withOpacity(.12),side:BorderSide(color:config.accent.withOpacity(.28)),label:Text(v,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800,fontSize:11)),onPressed:answered?null:()=>_complete(v==pair.english,v))).toList()),
    ]));
  }

  Widget _teamBuilder() {
    const core=['We','You','They'];
    final exact=core.contains(pair.english as String);
    final values=exact?core:englishOptions;
    return _panel(child:Column(children:[
      Text('TEAM BUILDER',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),
      Text('Forma el grupo: ${pair.english}',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:18),
      Wrap(spacing:10,runSpacing:10,alignment:WrapAlignment.center,children:values.map((v)=>InkWell(onTap:answered?null:()=>_complete(v==pair.english,v),borderRadius:BorderRadius.circular(20),child:Container(width:145,height:105,padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:config.accent.withOpacity(.08),borderRadius:BorderRadius.circular(20),border:Border.all(color:config.accent.withOpacity(.2))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.groups_rounded,color:config.accent,size:34),const SizedBox(height:6),Text(v,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800,fontSize:10.5))])))).toList())
    ]));
  }

  Widget _dragBins(String left, String right) {
    final correctLeft = (pair.english as String).toLowerCase().contains('many') || ['I','You','He','She','It'].contains(pair.english as String);
    return _panel(child: Column(children: [_titlePrompt('Arrastra la tarjeta al contenedor que corresponda.'), const SizedBox(height: 18), Draggable<String>(data: pair.english as String, feedback: Material(color: Colors.transparent, child: _dragCard(pair.english as String)), childWhenDragging: Opacity(opacity: .25, child: _dragCard(pair.english as String)), child: _dragCard(pair.english as String)), const SizedBox(height: 20), Row(children: [Expanded(child: _dropBox(left, correctLeft)), const SizedBox(width: 10), Expanded(child: _dropBox(right, !correctLeft))]) ]));
  }

  Widget _dragCard(String text) => Container(width: 210, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: config.accent, borderRadius: BorderRadius.circular(18)), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF07182A), fontWeight: FontWeight.w900)));
  Widget _dropBox(String text, bool isCorrect) => DragTarget<String>(onAccept: (_) => _complete(isCorrect, isCorrect ? pair.english as String : text), builder: (_, __, ___) => Container(height: 90, decoration: BoxDecoration(color: Colors.white.withOpacity(.04), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white24, style: BorderStyle.solid)), alignment: Alignment.center, child: Text(text, style: TextStyle(color: config.accent, fontWeight: FontWeight.w900))));

  Widget _wordForge() => _panel(child: Column(children: [_titlePrompt('Forja la frase tocando las palabras en el orden correcto.'), const SizedBox(height: 18), Container(constraints: const BoxConstraints(minHeight: 62), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16)), child: Wrap(spacing: 8, runSpacing: 8, children: built.map((w) => Chip(label: Text(w))).toList())), const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, children: tokens.where((w) => !built.contains(w) || built.where((e)=>e==w).length < tokens.where((e)=>e==w).length).map((w) => ActionChip(label: Text(w), onPressed: answered ? null : () { setState(()=>built.add(w)); if (built.length == tokens.length) _complete(built.join(' ') == (pair.english as String).replaceAll(RegExp(r"[^A-Za-z0-9' ]"), '').trim()); })).toList())]));

  Widget _detectiveCase() => _panel(child: Column(children:[
    Text('IDENTITY DETECTIVE',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
    const SizedBox(height:10),
    Icon(Icons.fingerprint_rounded,color:config.accent,size:70),
    const SizedBox(height:10),
    Text('Pista: ${pair.english}',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),
    const SizedBox(height:16),
    SizedBox(height:190,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:englishOptions.length,separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(_,i){final value=englishOptions[i];return InkWell(onTap:answered?null:()=>_complete(value==pair.english,value),borderRadius:BorderRadius.circular(20),child:Container(width:155,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white.withOpacity(.045),borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.white12)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(i.isEven?Icons.person_pin_rounded:Icons.location_on_rounded,color:config.accent,size:40),const SizedBox(height:12),Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800,fontSize:12.5))])));}))
  ]));

  int? _numberFrom(String s) { const map={'Zero':0,'One':1,'Two':2,'Three':3,'Four':4,'Five':5,'Six':6,'Seven':7,'Eight':8,'Nine':9,'Ten':10,'Eleven':11,'Twelve':12,'Thirteen':13,'Fourteen':14,'Fifteen':15,'Sixteen':16,'Seventeen':17,'Eighteen':18,'Nineteen':19,'Twenty':20}; return map[s]; }
  Widget _numberPad() { final n=_numberFrom(pair.english as String); if (n == null || n > 10) return _meaningDragRound(); return _panel(child: Column(children: [_titlePrompt('Escucha y toca el número.', visual: IconButton.filled(onPressed: _speak, icon: const Icon(Icons.volume_up_rounded))), const SizedBox(height: 18), Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: List.generate(11, (i)=>InkWell(onTap: answered?null:()=>_complete(n == i, '$i'), child: Container(width: 62,height:62,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.white.withOpacity(.05),borderRadius:BorderRadius.circular(18),border:Border.all(color:Colors.white12)),child:Text('$i',style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900))))))])); }

  Widget _codeLock() {
    final target = <String, int>{
      'Eleven': 11,
      'Twelve': 12,
      'Thirteen': 13,
      'Fourteen': 14,
      'Fifteen': 15,
      'Sixteen': 16,
      'Seventeen': 17,
      'Eighteen': 18,
      'Nineteen': 19,
      'Twenty': 20,
    }[pair.english as String] ?? 0;
    if (target == 0) return _meaningDragRound();
    return _panel(child:Column(children:[
      Text('NUMBER CODE',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
      const SizedBox(height:10),
      const Icon(Icons.lock_rounded,color:Colors.white,size:58),
      const SizedBox(height:10),
      Text(pair.english as String,style:const TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w900)),
      const SizedBox(height:18),
      Wrap(spacing:10,runSpacing:10,alignment:WrapAlignment.center,children:List.generate(10, (i) => i + 11).map((n)=>InkWell(onTap:answered?null:()=>_complete(n==target,'$n'),borderRadius:BorderRadius.circular(16),child:Container(width:72,height:58,alignment:Alignment.center,decoration:BoxDecoration(color:config.accent.withOpacity(.1),borderRadius:BorderRadius.circular(16),border:Border.all(color:config.accent.withOpacity(.28))),child:Text('$n',style:TextStyle(color:config.accent,fontSize:20,fontWeight:FontWeight.w900))))).toList())
    ]));
  }

  Color _colorFor(String s) {
    switch (s.toLowerCase()) {
      case 'white': return Colors.white;
      case 'black': return Colors.black;
      case 'red': return Colors.red;
      case 'pink': return Colors.pink;
      case 'yellow': return Colors.yellow;
      case 'blue': return Colors.blue;
      case 'turquoise blue': return Colors.cyan;
      case 'navy blue': return const Color(0xFF153A70);
      case 'green': return Colors.green;
      case 'violet': return Colors.deepPurple;
      case 'orange': return Colors.orange;
      case 'brown': return Colors.brown;
      case 'grey': return Colors.grey;
      case 'silver': return const Color(0xFFB8C2CC);
      case 'gold-coloured': return const Color(0xFFD4AF37);
      case 'light': return const Color(0xFFEAF5FF);
      case 'dark': return const Color(0xFF18212B);
      case 'bright': return const Color(0xFFFFF176);
      default: return config.accent;
    }
  }

  Widget _colorPalette() => _panel(
        child: Column(
          children: [
            _titlePrompt('Toca la muestra que representa la palabra.', visual: Icon(Icons.brush_rounded, color: config.accent, size: 52)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: englishOptions.map((name) {
                return GestureDetector(
                  onTap: answered ? null : () => _complete(name == pair.english, name),
                  child: Container(
                    width: 82,
                    height: 82,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: _colorFor(name), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white24, width: 3)),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                      child: Text(name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );

  Widget _familyTree() {
    IconData familyIcon(String value) {
      final v = value.toLowerCase();
      if (v.contains('grand')) return Icons.elderly_rounded;
      if (v.contains('mother') || v.contains('wife') || v.contains('aunt') || v.contains('sister') || v.contains('daughter') || v.contains('girlfriend') || v.contains('niece')) return Icons.woman_rounded;
      if (v.contains('father') || v.contains('husband') || v.contains('uncle') || v.contains('brother') || v.contains('son') || v.contains('boyfriend') || v.contains('nephew')) return Icons.man_rounded;
      return Icons.family_restroom_rounded;
    }
    return _panel(child: Column(children:[
      Text('FAMILY TREE',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
      const SizedBox(height:8),
      Text('Ubica: ${pair.english}',style:const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),
      const SizedBox(height:16),
      Wrap(spacing:10,runSpacing:10,alignment:WrapAlignment.center,children:englishOptions.map((value)=>InkWell(
        onTap:answered?null:()=>_complete(value==pair.english,value),
        borderRadius:BorderRadius.circular(18),
        child:Container(width:132,height:92,decoration:BoxDecoration(color:config.accent.withOpacity(.08),borderRadius:BorderRadius.circular(18),border:Border.all(color:config.accent.withOpacity(.22))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(familyIcon(value),color:config.accent,size:32),const SizedBox(height:5),Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:10.5,fontWeight:FontWeight.w800))])),
      )).toList()),
    ]));
  }

  Widget _twoGates() {
    final eng=(pair.english as String).trim().toLowerCase();
    final correct=eng.startsWith('an ')?'AN':'A';
    return _panel(child:Column(children:[
      Text('ARTICLE GATE',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
      const SizedBox(height:8),
      Text(pair.english as String,style:const TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w900)),
      const SizedBox(height:18),
      Row(children:['A','AN'].map((g)=>Expanded(child:Padding(padding:const EdgeInsets.all(6),child:InkWell(onTap:answered?null:()=>_complete(g==correct,g),child:Container(height:150,decoration:BoxDecoration(color:config.accent.withOpacity(.10),borderRadius:const BorderRadius.vertical(top:Radius.circular(70)),border:Border.all(color:config.accent.withOpacity(.5))),alignment:Alignment.center,child:Text(g,style:TextStyle(color:config.accent,fontSize:32,fontWeight:FontWeight.w900))))))).toList())
    ]));
  }

  Widget _inventoryShelf() {
    final eng=(pair.english as String).trim().toLowerCase();
    String expected='OTHER';
    for(final subject in ['I','YOU','HE','SHE','WE','THEY']){if(eng==subject.toLowerCase()||eng.startsWith('${subject.toLowerCase()} ')){expected=subject;break;}}
    final values=expected=='OTHER'?englishOptions:<String>['I','YOU','HE','SHE','WE','THEY'];
    return _panel(child:Column(children:[
      Text('INVENTORY RUSH',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),Text(pair.english as String,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:16),
      Container(height:70,decoration:BoxDecoration(color:Colors.white.withOpacity(.035),borderRadius:BorderRadius.circular(18)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[Icons.directions_car_rounded,Icons.pets_rounded,Icons.home_rounded].map((i)=>Icon(i,color:config.accent,size:34)).toList())),const SizedBox(height:15),
      Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,children:values.map((v)=>ActionChip(backgroundColor:config.accent.withOpacity(.1),side:BorderSide(color:config.accent.withOpacity(.25)),label:Text(v,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800,fontSize:10.5)),onPressed:answered?null:()=>_complete(expected=='OTHER'?v==pair.english:v==expected,v))).toList())
    ]));
  }

  Widget _avatarBuilder() {
    IconData iconFor(String value) {
      final v = value.toLowerCase();
      if (v.contains('hair')) return Icons.face_retouching_natural_rounded;
      if (v.contains('eye')) return Icons.remove_red_eye_rounded;
      if (v.contains('beard') || v.contains('moustache')) return Icons.face_4_rounded;
      if (v.contains('glasses')) return Icons.visibility_rounded;
      if (v.contains('bald')) return Icons.face_6_rounded;
      if (v.contains('tall') || v.contains('short')) return Icons.height_rounded;
      if (v.contains('thin') || v.contains('fat') || v.contains('weight')) return Icons.accessibility_new_rounded;
      return Icons.face_rounded;
    }
    return _panel(child:Column(children:[
      Text('AVATAR BUILDER',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
      const SizedBox(height:8),
      Text('Construye: ${pair.english}',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),
      const SizedBox(height:16),
      CircleAvatar(radius:46,backgroundColor:config.accent.withOpacity(.12),child:Icon(Icons.face_rounded,color:config.accent,size:58)),
      const SizedBox(height:16),
      Wrap(spacing:9,runSpacing:9,alignment:WrapAlignment.center,children:englishOptions.map((value)=>InkWell(
        onTap:answered?null:()=>_complete(value==pair.english,value),
        borderRadius:BorderRadius.circular(16),
        child:Container(width:132,constraints:const BoxConstraints(minHeight:86),padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:Colors.white.withOpacity(.04),borderRadius:BorderRadius.circular(16),border:Border.all(color:Colors.white12)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(iconFor(value),color:config.accent),const SizedBox(height:5),Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800,fontSize:10.5))]))
      )).toList())
    ]));
  }

  Widget _bodyScanner()=>_panel(child:Column(children:[
    Text('BODY SCAN',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
    const SizedBox(height:8),
    Text('Identifica: ${pair.english}',style:const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),
    const SizedBox(height:12),
    SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.accessibility_new_rounded,color:Colors.white24,size:220),
          Positioned(
            left: 8, right: 8, bottom: 8,
            child: Wrap(
              spacing: 7, runSpacing: 7, alignment: WrapAlignment.center,
              children: englishOptions.map((name) => ActionChip(
                backgroundColor: config.accent.withOpacity(.12),
                side: BorderSide(color: config.accent.withOpacity(.25)),
                label: Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                onPressed: answered ? null : () => _complete(name == pair.english, name),
              )).toList(),
            ),
          ),
        ],
      ),
    ),
  ]));

  Widget _clockFace() {
    final english = (pair.english as String).toLowerCase();
    final clockable = english.startsWith("it's ") &&
        (english.contains('past') || english.contains(' to ') || english.contains('on the dot'));

    return _panel(
      child: Column(
        children: [
          Text('CLOCK RACE', style: TextStyle(color: config.accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(pair.english as String, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(shape: BoxShape.circle, color: config.accent.withOpacity(.08), border: Border.all(color: config.accent.withOpacity(.65), width: 4)),
            child: Center(child: Icon(clockable ? Icons.schedule_rounded : Icons.calendar_today_rounded, color: config.accent, size: 72)),
          ),
          const SizedBox(height: 16),
          if (clockable)
            Text('Elige la expresión que coincide con la hora.', style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w700))
          else
            Text('Relaciona la expresión de tiempo.', style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: englishOptions.map((value) => ActionChip(
              backgroundColor: config.accent.withOpacity(.08),
              side: BorderSide(color: config.accent.withOpacity(.22)),
              label: Text(value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
              onPressed: answered ? null : () => _complete(value == pair.english, value),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _sportsBoard() {
    IconData sportIcon(String value) {
      final v=value.toLowerCase();
      if(v.contains('football')||v.contains('soccer')) return Icons.sports_soccer_rounded;
      if(v.contains('basketball')) return Icons.sports_basketball_rounded;
      if(v.contains('tennis')||v.contains('badminton')) return Icons.sports_tennis_rounded;
      if(v.contains('swim')||v.contains('water polo')) return Icons.pool_rounded;
      if(v.contains('cycling')) return Icons.directions_bike_rounded;
      if(v.contains('golf')) return Icons.sports_golf_rounded;
      if(v.contains('baseball')) return Icons.sports_baseball_rounded;
      if(v.contains('hockey')) return Icons.sports_hockey_rounded;
      if(v.contains('boxing')) return Icons.sports_mma_rounded;
      if(v.contains('ski')||v.contains('skating')) return Icons.downhill_skiing_rounded;
      if(v.contains('hiking')) return Icons.hiking_rounded;
      return Icons.sports_rounded;
    }
    return _panel(child:Column(children:[
      Text('SPORTS COACH',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
      const SizedBox(height:8),Text(pair.english as String,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(height:18),
      Wrap(spacing:10,runSpacing:10,alignment:WrapAlignment.center,children:englishOptions.map((value)=>InkWell(
        onTap:answered?null:()=>_complete(value==pair.english,value),borderRadius:BorderRadius.circular(20),
        child:Container(width:145,constraints:const BoxConstraints(minHeight:118),padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:config.accent.withOpacity(.08),borderRadius:BorderRadius.circular(20),border:Border.all(color:config.accent.withOpacity(.22))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(sportIcon(value),color:config.accent,size:40),const SizedBox(height:8),Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:10.5,fontWeight:FontWeight.w800))]))
      )).toList())
    ]));
  }

  Widget _climb()=>_panel(child:Column(children:[
    Text('COMPARISON CLIMB',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
    const SizedBox(height:8),Text(pair.english as String,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:14),
    Column(children:List.generate(englishOptions.length,(i){final value=englishOptions[i];return InkWell(onTap:answered?null:()=>_complete(value==pair.english,value),child:Container(margin:const EdgeInsets.only(bottom:8),width:(120 + i * 42).toDouble(),height:44,alignment:Alignment.center,decoration:BoxDecoration(color:config.accent.withOpacity(.07+i*.025),borderRadius:BorderRadius.circular(12)),child:Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.w800))));}))
  ]));

  Widget _wishWheel()=>_panel(child:Column(children:[
    Text('WISH WHEEL',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),
    Text('Ocasión: ${pair.english}',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:14),
    Transform.rotate(angle:round*.9,child:Container(width:120,height:120,decoration:BoxDecoration(shape:BoxShape.circle,gradient:SweepGradient(colors:[config.accent,config.accent.withOpacity(.18),config.accent,config.accent.withOpacity(.18)])),child:const Icon(Icons.celebration_rounded,color:Color(0xFF07182A),size:48))),const SizedBox(height:16),
    SizedBox(height:72,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:englishOptions.length,separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(_,i)=>ActionChip(backgroundColor:Colors.white.withOpacity(.05),side:BorderSide(color:Colors.white.withOpacity(.1)),label:Text(englishOptions[i],style:const TextStyle(color:Colors.white,fontSize:11)),onPressed:answered?null:()=>_complete(englishOptions[i]==pair.english,englishOptions[i]))))
  ]));

  Widget _petCare() {
    const emoji = <String,String>{
      'Dog':'🐶','Puppy':'🐕','Cat':'🐱','Bird':'🐦','Parrot':'🦜','Budgerigar':'🐦','Fish':'🐟','Tortoise':'🐢','Chameleon':'🦎','Ferret':'🐾','Iguana':'🦎','Hamster':'🐹','Rabbit':'🐰',
    };
    return _panel(child:Column(children:[
      Text('PET CARE',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),
      Text('¿Qué mascota es “${pair.english}”?',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:16),
      Wrap(spacing:12,runSpacing:12,alignment:WrapAlignment.center,children:englishOptions.map((value)=>InkWell(onTap:answered?null:()=>_complete(value==pair.english,value),borderRadius:BorderRadius.circular(22),child:Container(width:112,height:112,decoration:BoxDecoration(color:config.accent.withOpacity(.07),borderRadius:BorderRadius.circular(22),border:Border.all(color:config.accent.withOpacity(.18))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(emoji[value] ?? '🐾',style:const TextStyle(fontSize:44)),const SizedBox(height:5),Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800,fontSize:10))])))).toList())
    ]));
  }

  Widget _timeline() {
    const subjects = ['I','YOU','HE','SHE','WE','THEY'];
    final e=(pair.english as String).trim().toLowerCase();
    String? expected;
    for(final subject in subjects){
      final low=subject.toLowerCase();
      if(e.startsWith('$low ')){expected=subject;break;}
    }
    if(expected==null) return _meaningDragRound();
    return _panel(child:Column(children:[
      Text('ROUTINE BUILDER',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),
      const Text('Clasifica la rutina según quién la realiza',style:TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:8),
      Text(pair.english as String,textAlign:TextAlign.center,style:TextStyle(color:config.accent,fontSize:14,fontWeight:FontWeight.w800)),const SizedBox(height:16),
      Draggable<String>(data:pair.english as String,feedback:Material(color:Colors.transparent,child:_dragCard(pair.english as String)),childWhenDragging:Opacity(opacity:.25,child:_dragCard(pair.english as String)),child:_dragCard(pair.english as String)),const SizedBox(height:16),
      Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,children:subjects.map((label)=>DragTarget<String>(onAccept:(_)=>_complete(label==expected,label),builder:(_,__,___)=>Container(width:94,height:76,decoration:BoxDecoration(color:config.accent.withOpacity(.07),borderRadius:BorderRadius.circular(18),border:Border.all(color:config.accent.withOpacity(.2))),alignment:Alignment.center,child:Text(label,style:TextStyle(color:config.accent,fontWeight:FontWeight.w900))))).toList())
    ]));
  }

  Widget _passport()=>_panel(child:Column(children:[
    Text('PASSPORT RUN',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),Text(pair.english as String,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:15),
    Container(width:180,height:115,decoration:BoxDecoration(color:const Color(0xFF253A57),borderRadius:BorderRadius.circular(16),border:Border.all(color:config.accent)),child:Center(child:Icon(Icons.public_rounded,color:config.accent,size:62))),const SizedBox(height:14),
    Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,children:englishOptions.map((v)=>InkWell(onTap:answered?null:()=>_complete(v==pair.english,v),child:Container(padding:const EdgeInsets.symmetric(horizontal:13,vertical:10),decoration:BoxDecoration(border:Border.all(color:config.accent.withOpacity(.35)),borderRadius:BorderRadius.circular(8)),child:Text(v,style:const TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.w800))))).toList())
  ]));

  Widget _cafeTray()=>_panel(child:Column(children:[
    Text('BREAKFAST CAFÉ',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),Text(pair.english as String,style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:14),
    Container(height:120,decoration:BoxDecoration(color:const Color(0xFF342A25),borderRadius:BorderRadius.circular(28),border:Border.all(color:config.accent.withOpacity(.35))),child:const Center(child:Text('☕   🥛   🍞   🍳',style:TextStyle(fontSize:41)))),const SizedBox(height:14),
    SizedBox(height:74,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:englishOptions.length,separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(_,i)=>ActionChip(backgroundColor:Colors.white.withOpacity(.05),label:Text(englishOptions[i],style:const TextStyle(color:Colors.white,fontSize:10.5)),onPressed:answered?null:()=>_complete(englishOptions[i]==pair.english,englishOptions[i]))))
  ]));

  Widget _sliceBoard(String a,String b,String c,String d) {
    String fruitEmoji(String v){final x=v.toLowerCase();if(x.contains('apple'))return '🍎';if(x.contains('orange')||x.contains('tangerine'))return '🍊';if(x.contains('banana'))return '🍌';if(x.contains('lemon'))return '🍋';if(x.contains('watermelon'))return '🍉';if(x.contains('grape'))return '🍇';if(x.contains('strawberry'))return '🍓';if(x.contains('cherry'))return '🍒';if(x.contains('peach'))return '🍑';if(x.contains('pear'))return '🍐';if(x.contains('pineapple'))return '🍍';if(x.contains('coconut'))return '🥥';if(x.contains('avocado'))return '🥑';if(x.contains('kiwi'))return '🥝';if(x.contains('mango'))return '🥭';return '🍈';}
    return _panel(child:Column(children:[
      Text('FRUIT SLICE',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),Text('Corta: ${pair.english}',style:const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(height:18),
      Wrap(spacing:12,runSpacing:12,alignment:WrapAlignment.center,children:englishOptions.map((value)=>GestureDetector(onTap:answered?null:()=>_complete(value==pair.english,value),child:Container(width:128,height:105,padding:const EdgeInsets.all(8),alignment:Alignment.center,decoration:BoxDecoration(color:Colors.white.withOpacity(.05),borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white12)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(fruitEmoji(value),style:const TextStyle(fontSize:40)),Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w800))])))).toList())
    ]));
  }

  Widget _garden() {
    String vegEmoji(String v){final x=v.toLowerCase();if(x.contains('carrot'))return '🥕';if(x.contains('onion'))return '🧅';if(x.contains('tomato'))return '🍅';if(x.contains('potato'))return '🥔';if(x.contains('garlic'))return '🧄';if(x.contains('cucumber'))return '🥒';if(x.contains('broccoli'))return '🥦';if(x.contains('pepper'))return '🫑';if(x.contains('mushroom'))return '🍄';if(x.contains('lettuce')||x.contains('spinach')||x.contains('chard'))return '🥬';return '🌱';}
    return _panel(child:Column(children:[Text('VEGGIE GARDEN',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),Text('Planta: ${pair.english}',style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:18),Wrap(spacing:10,runSpacing:10,alignment:WrapAlignment.center,children:englishOptions.map((value)=>InkWell(onTap:answered?null:()=>_complete(value==pair.english,value),borderRadius:BorderRadius.circular(18),child:Container(width:130,height:100,padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:const Color(0xFF193222),borderRadius:BorderRadius.circular(18)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(vegEmoji(value),style:const TextStyle(fontSize:34)),Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:9.5,fontWeight:FontWeight.w800))])))).toList())]));
  }

  Widget _shop()=>_panel(child:Column(children:[
    Text('SHOPPING CART',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),Text(pair.english as String,style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:14),
    Row(children:[Expanded(child:Container(height:115,decoration:BoxDecoration(color:Colors.white.withOpacity(.04),borderRadius:BorderRadius.circular(18)),child:Icon(Icons.checkroom_rounded,color:config.accent,size:58))),const SizedBox(width:10),Expanded(child:Container(height:115,decoration:BoxDecoration(color:Colors.white.withOpacity(.04),borderRadius:BorderRadius.circular(18)),child:Icon(Icons.shopping_cart_checkout_rounded,color:config.accent,size:58)))]),const SizedBox(height:12),
    SizedBox(height:70,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:englishOptions.length,separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(_,i)=>ActionChip(backgroundColor:config.accent.withOpacity(.08),label:Text(englishOptions[i],style:const TextStyle(color:Colors.white,fontSize:10.5)),onPressed:answered?null:()=>_complete(englishOptions[i]==pair.english,englishOptions[i]))))
  ]));

  Widget _careerCards() => _panel(child:Column(children:[
    Text('CAREER MATCH',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),
    Text(pair.english as String,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(height:15),
    SizedBox(height:210,child:PageView.builder(controller:PageController(viewportFraction:.76),itemCount:options.length,itemBuilder:(_,i){final v=options[i];return Padding(padding:const EdgeInsets.symmetric(horizontal:6),child:InkWell(onTap:answered?null:()=>_answer(v),borderRadius:BorderRadius.circular(23),child:Container(decoration:BoxDecoration(color:config.accent.withOpacity(.07),borderRadius:BorderRadius.circular(23),border:Border.all(color:config.accent.withOpacity(.2))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(i==0?Icons.badge_rounded:i==1?Icons.business_center_rounded:i==2?Icons.school_rounded:Icons.apartment_rounded,color:config.accent,size:46),const SizedBox(height:12),Text(v,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:13,fontWeight:FontWeight.w800))]))));}))
  ]));

  Widget _travelMap()=>_panel(child:Column(children:[
    Text('AMERICA TRIP',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),Text(pair.english as String,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:12),
    SizedBox(height:150,child:Stack(children:[Positioned(left:24,top:78,child:_mapPin('A')),Positioned(left:142,top:26,child:_mapPin('B')),Positioned(right:24,bottom:22,child:_mapPin('C')),Positioned(left:105,top:65,child:Transform.rotate(angle:.45,child:Icon(Icons.flight_rounded,color:config.accent,size:42)))])),
    _choiceStrip()
  ]));

  Widget _cityGrid()=>_panel(child:Column(children:[
    Text('CITY NAVIGATOR',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),
    Text(pair.english as String,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:14),
    Wrap(spacing:9,runSpacing:9,alignment:WrapAlignment.center,children:englishOptions.map((value)=>SizedBox(width:145,child:_placeTile(value,Icons.location_on_rounded,value))).toList())
  ]));

  Widget _placeTile(String value,IconData icon,String label)=>InkWell(onTap:answered?null:()=>_complete(value==pair.english,value),borderRadius:BorderRadius.circular(19),child:Container(height:145,decoration:BoxDecoration(color:config.accent.withOpacity(.07),borderRadius:BorderRadius.circular(19),border:Border.all(color:config.accent.withOpacity(.18))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:config.accent,size:42),const SizedBox(height:9),Text(label,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w900))])));

  Widget _roomDesigner()=>_panel(child:Column(children:[
    Text('ROOM DESIGNER',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),
    Text('Encuentra: ${pair.english}',style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:12),
    Wrap(spacing:9,runSpacing:9,alignment:WrapAlignment.center,children:englishOptions.map((value)=>_roomTap(value,Icons.chair_alt_rounded)).toList())
  ]));

  Widget _roomTap(String value,IconData icon)=>InkWell(onTap:answered?null:()=>_complete(value==pair.english,value),borderRadius:BorderRadius.circular(15),child:Container(width:125,height:72,decoration:BoxDecoration(color:config.accent.withOpacity(.07),borderRadius:BorderRadius.circular(15),border:Border.all(color:config.accent.withOpacity(.15))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:config.accent,size:31),Text(value,style:const TextStyle(color:Colors.white,fontSize:9.5,fontWeight:FontWeight.w800))])));

  Widget _cameraFrame()=>_panel(child:Column(children:[
    Text('ACTION CAMERA',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),Text(pair.english as String,style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:12),
    Container(height:165,decoration:BoxDecoration(color:Colors.black26,borderRadius:BorderRadius.circular(18),border:Border.all(color:Colors.white24,width:2)),child:Stack(children:[Center(child:Icon(Icons.directions_run_rounded,color:config.accent,size:82)),const Positioned(top:10,right:12,child:Icon(Icons.fiber_manual_record_rounded,color:Colors.red,size:18))])),const SizedBox(height:12),_choiceStrip()
  ]));

  Widget _hideAndSeek()=>_panel(child:Column(children:[
    Text('HIDE & SEEK',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),
    Text('Ubica: ${pair.english}',style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:12),
    Container(height:140,decoration:BoxDecoration(color:const Color(0xFF132C42),borderRadius:BorderRadius.circular(18)),child:const Stack(children:[Positioned(left:35,bottom:20,child:Icon(Icons.chair_alt_rounded,color:Colors.white38,size:55)),Positioned(right:35,bottom:20,child:Icon(Icons.table_restaurant_rounded,color:Colors.white38,size:65)),Positioned(right:15,top:25,child:Icon(Icons.door_front_door_rounded,color:Colors.white38,size:55))])),
    const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,children:englishOptions.map((value)=>ActionChip(backgroundColor:config.accent.withOpacity(.08),side:BorderSide(color:config.accent.withOpacity(.2)),label:Text(value,style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w800)),onPressed:answered?null:()=>_complete(value==pair.english,value))).toList())
  ]));

  Widget _spot(String value)=>GestureDetector(onTap:answered?null:()=>_complete(value==pair.english,value),child:Container(width:34,height:34,decoration:BoxDecoration(color:config.accent.withOpacity(.38),shape:BoxShape.circle,border:Border.all(color:config.accent,width:2)),child:const Icon(Icons.touch_app_rounded,color:Colors.white,size:17)));

  Widget _interview()=>_panel(child:Column(children:[
    Text('JOB INTERVIEW',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:[CircleAvatar(backgroundColor:config.accent.withOpacity(.2),child:Icon(Icons.person,color:config.accent)),const SizedBox(width:8),Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white.withOpacity(.06),borderRadius:BorderRadius.circular(16)),child:Text('Buscamos: ${pair.english}',style:const TextStyle(color:Colors.white70,fontWeight:FontWeight.w800))) ]),const SizedBox(height:16),
    SizedBox(height:200,child:PageView.builder(itemCount:englishOptions.length,controller:PageController(viewportFraction:.78),itemBuilder:(_,i)=>Padding(padding:const EdgeInsets.symmetric(horizontal:6),child:InkWell(onTap:answered?null:()=>_complete(englishOptions[i]==pair.english,englishOptions[i]),child:Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:config.accent.withOpacity(.07),borderRadius:BorderRadius.circular(22),border:Border.all(color:config.accent.withOpacity(.18))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.record_voice_over_rounded,color:config.accent,size:42),const SizedBox(height:12),Text(englishOptions[i],textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800))]))))))
  ]));

  Widget _lockers() {
    const possessives = ['My','Your','His','Her','Its','Our','Their'];
    final e = (pair.english as String).trim();
    String? expected;
    for (final p in possessives) {
      final low = p.toLowerCase();
      final source = e.toLowerCase();
      if (source == low || source.startsWith('$low ')) {
        expected = p;
        break;
      }
    }
    if (expected == null) return _meaningDragRound();
    return _panel(child:Column(children:[
      Text('OWNERSHIP LOCKER',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
      const SizedBox(height:8),
      Text(pair.english as String,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),
      const SizedBox(height:16),
      Wrap(spacing:9,runSpacing:9,alignment:WrapAlignment.center,children:possessives.map((label)=>InkWell(
        onTap:answered?null:()=>_complete(label==expected,label),borderRadius:BorderRadius.circular(14),
        child:Container(width:104,height:112,decoration:BoxDecoration(color:Colors.white.withOpacity(.045),borderRadius:BorderRadius.circular(14),border:Border.all(color:config.accent.withOpacity(.25))),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.lock_rounded,color:config.accent),const SizedBox(height:8),Text(label.toUpperCase(),style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:10))]))
      )).toList())
    ]));
  }

  Widget _sizeSorter()=>_panel(child:Column(children:[
    Text('SIZE SORTER',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),Text('Compara: ${pair.english}',style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:18),
    Wrap(spacing:10,runSpacing:10,alignment:WrapAlignment.center,children:List.generate(englishOptions.length,(i){final value=englishOptions[i];final h=58.0+(i*13);return InkWell(onTap:answered?null:()=>_complete(value==pair.english,value),borderRadius:BorderRadius.circular(14),child:Container(width:132,height:h.clamp(58,110),padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:config.accent.withOpacity(.10+i*.025),borderRadius:BorderRadius.circular(14),border:Border.all(color:config.accent.withOpacity(.2))),alignment:Alignment.center,child:Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w800))));}).toList())
  ]));

  Widget _calendar()=>_panel(child:Column(children:[
    Text('CALENDAR DASH',style:TextStyle(color:config.accent,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),const SizedBox(height:8),Text(pair.english as String,style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:16),
    Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,children:englishOptions.map((value)=>InkWell(onTap:answered?null:()=>_complete(value==pair.english,value),borderRadius:BorderRadius.circular(13),child:Container(width:130,padding:const EdgeInsets.symmetric(vertical:14,horizontal:7),decoration:BoxDecoration(color:config.accent.withOpacity(.08),borderRadius:BorderRadius.circular(13),border:Border.all(color:config.accent.withOpacity(.17))),alignment:Alignment.center,child:Text(value,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:10))))).toList())
  ]));

  Widget _choiceStrip()=>SizedBox(height:72,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:englishOptions.length,separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(_,i)=>ActionChip(backgroundColor:Colors.white.withOpacity(.05),side:BorderSide(color:Colors.white.withOpacity(.1)),label:Text(englishOptions[i],style:const TextStyle(color:Colors.white,fontSize:10.5)),onPressed:answered?null:()=>_complete(englishOptions[i]==pair.english,englishOptions[i]))));

  Widget _mapPin(String label)=>Container(width:48,height:48,decoration:BoxDecoration(color:config.accent.withOpacity(.12),shape:BoxShape.circle,border:Border.all(color:config.accent.withOpacity(.38))),alignment:Alignment.center,child:Text(label,style:TextStyle(color:config.accent,fontWeight:FontWeight.w900)));

  Widget _feedback() {
    final ok = lastCorrect == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: (ok ? const Color(0xFF3DDC97) : const Color(0xFFFF667A)).withOpacity(.10), borderRadius: BorderRadius.circular(20), border: Border.all(color: (ok ? const Color(0xFF3DDC97) : const Color(0xFFFF667A)).withOpacity(.35))),
      child: Row(children:[Icon(ok?Icons.bolt_rounded:Icons.lightbulb_rounded,color:ok?const Color(0xFF3DDC97):const Color(0xFFFFD166)),const SizedBox(width:12),Expanded(child:Text(ok?'¡Bien! La idea quedó reforzada.':'Recuerda: ${pair.english} = ${pair.english}',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800,height:1.35)))]),
    );
  }
}
