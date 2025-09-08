import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as timezone;
import 'package:timezone/data/latest.dart' as tz_data;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();
  await Notifications.init();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AppState state = AppState();
  
  @override
  void initState() {
    super.initState();
    // Load saved data when app starts
    state.loadFromPreferences();
  }
  
  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'aWaWa',
        debugShowCheckedModeBanner: false,
        home: const Home(),
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.red,
            secondary: Colors.redAccent,
            surface: Color(0xFF121212),
            background: Color(0xFF121212),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            onBackground: Colors.white,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: Colors.white),
            displayMedium: TextStyle(color: Colors.white),
            displaySmall: TextStyle(color: Colors.white),
            headlineLarge: TextStyle(color: Colors.white),
            headlineMedium: TextStyle(color: Colors.white),
            headlineSmall: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white),
            labelLarge: TextStyle(color: Colors.white),
            labelMedium: TextStyle(color: Colors.white),
            labelSmall: TextStyle(color: Colors.white),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF121212),
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF1E1E1E),
          ),
          listTileTheme: const ListTileThemeData(
            textColor: Colors.white,
            iconColor: Colors.white,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white70),
            hintStyle: TextStyle(color: Colors.white54),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required Widget child})
    : super(notifier: state, child: child);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class AppState extends ChangeNotifier {
  final List<InventoryItem> inventory = [];
  final List<Mission> missions = [];
  final List<Mission> activeMissions = [];
  String inventoryQuery = '';
  final Set<String> inventoryFilters = {};

  // Load data from local preferences
  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load inventory
    final inventoryJson = prefs.getString('inventory');
    if (inventoryJson != null) {
      final List<dynamic> inventoryList = jsonDecode(inventoryJson);
      inventory.clear();
      inventory.addAll(inventoryList.map((item) => InventoryItem.fromJson(item)));
    }
    
    // Load missions
    final missionsJson = prefs.getString('missions');
    if (missionsJson != null) {
      final List<dynamic> missionsList = jsonDecode(missionsJson);
      missions.clear();
      missions.addAll(missionsList.map((mission) => Mission.fromJson(mission)));
    }
    
    // Load active missions
    final activeMissionsJson = prefs.getString('activeMissions');
    if (activeMissionsJson != null) {
      final List<dynamic> activeMissionsList = jsonDecode(activeMissionsJson);
      activeMissions.clear();
      activeMissions.addAll(activeMissionsList.map((mission) => Mission.fromJson(mission)));
    }
    
    // Load inventory filters
    final filtersJson = prefs.getString('inventoryFilters');
    if (filtersJson != null) {
      final List<dynamic> filtersList = jsonDecode(filtersJson);
      inventoryFilters.clear();
      inventoryFilters.addAll(filtersList.cast<String>());
    }
    
    notifyListeners();
  }
  
  // Save data to local preferences
  Future<void> saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save inventory
    final inventoryJson = jsonEncode(inventory.map((item) => item.toJson()).toList());
    await prefs.setString('inventory', inventoryJson);
    
    // Save missions
    final missionsJson = jsonEncode(missions.map((mission) => mission.toJson()).toList());
    await prefs.setString('missions', missionsJson);
    
    // Save active missions
    final activeMissionsJson = jsonEncode(activeMissions.map((mission) => mission.toJson()).toList());
    await prefs.setString('activeMissions', activeMissionsJson);
    
    // Save inventory filters
    final filtersJson = jsonEncode(inventoryFilters.toList());
    await prefs.setString('inventoryFilters', filtersJson);
  }
  void addInventory(InventoryItem i) {
    inventory.add(i);
    saveToPreferences();
    notifyListeners();
  }

  void updateInventoryQuery(String q) {
    inventoryQuery = q;
    notifyListeners();
  }

  void toggleFilter(String tag) {
    if (inventoryFilters.contains(tag)) {
      inventoryFilters.remove(tag);
    } else {
      inventoryFilters.add(tag);
    }
    saveToPreferences();
    notifyListeners();
  }

  List<InventoryItem> filteredInventory() {
    final q = inventoryQuery.trim().toLowerCase();
    return inventory.where((i) {
      final tagOk =
          inventoryFilters.isEmpty ||
          i.missionTypes.any(inventoryFilters.contains);
      if (q.isEmpty) return tagOk;
      final hay = '${i.name} ${i.notes}'.toLowerCase();
      return tagOk && _fuzzy(hay, q);
    }).toList();
  }

  static bool _fuzzy(String text, String pattern) {
    int ti = 0;
    for (int pi = 0; pi < pattern.length; pi++) {
      final ch = pattern.codeUnitAt(pi);
      bool found = false;
      while (ti < text.length) {
        if (text.codeUnitAt(ti) == ch) {
          found = true;
          ti++;
          break;
        }
        ti++;
      }
      if (!found) return false;
    }
    return true;
  }

  void addMission(Mission m) {
    missions.add(m);
    saveToPreferences();
    notifyListeners();
  }

  void activateMission(Mission m) async {
    if (!activeMissions.contains(m)) {
      activeMissions.add(m);
      await Notifications.scheduleMissionReminder(m);
      await saveToPreferences();
      notifyListeners();
    }
  }

  void completeMission(Mission m) {
    activeMissions.remove(m);
    saveToPreferences();
    notifyListeners();
  }

  void toggleTodo(Mission m, int idx) {
    m.todos[idx] = m.todos[idx].copyWith(done: !m.todos[idx].done);
    saveToPreferences();
    notifyListeners();
  }

  void addTodo(Mission m, TodoItem t) {
    m.todos.add(t);
    saveToPreferences();
    notifyListeners();
  }

  void addMissionItem(Mission m, MissionEntry e) {
    m.items.add(e);
    saveToPreferences();
    notifyListeners();
  }

  void updateMissionNotes(Mission m, String v) {
    m.notes = v;
    saveToPreferences();
    notifyListeners();
  }

  void toggleMissionItem(Mission m, int idx) {
    m.items[idx].done = !m.items[idx].done;
    saveToPreferences();
    notifyListeners();
  }
}

class Notifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  static Future<void> scheduleMissionReminder(Mission m) async {
    if (m.start == null) return;
    final when = m.start!;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'missions',
        'Missions',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      m.hashCode,
      'Mission start',
      '${m.name} starts',
      timezone.TZDateTime.from(when, timezone.local),
      details,

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: m.name,
      matchDateTimeComponents: null,
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int idx = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const InventoryScreen(),
      const MissionsScreen(),
      const ActiveMissionsScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[idx]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => setState(() => idx = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            label: 'Missions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            label: 'Active',
          ),
        ],
      ),
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});
  static const tags = ['climbing', 'foreign', 'driving'];
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.filteredInventory();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search inventory',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: state.updateInventoryQuery,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: tags
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(t),
                      selected: state.inventoryFilters.contains(t),
                      onSelected: (_) => state.toggleFilter(t),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: state,
            builder: (_, __) {
              final list = state.filteredInventory();
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final it = list[i];
                  return Card(
                    child: ListTile(
                      leading: it.images.isNotEmpty
                          ? Image.file(
                              it.images.first.toFile(),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text('${it.name} ×${it.quantity}'),
                      subtitle: Text(it.missionTypes.join(', ')),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InventoryDetail(item: it),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () async {
              final created = await Navigator.push<InventoryItem>(
                context,
                MaterialPageRoute(builder: (_) => const AddInventoryScreen()),
              );
              if (created != null) AppScope.of(context).addInventory(created);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
          ),
        ),
      ],
    );
  }
}

class InventoryDetail extends StatelessWidget {
  final InventoryItem item;
  const InventoryDetail({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.images
                .map(
                  (f) => Image.file(
                    f.toFile(),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Quantity: ${item.quantity}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Tags: ${item.missionTypes.join(', ')}'),
          const SizedBox(height: 8),
          Text(item.notes.isEmpty ? 'No notes' : item.notes),
        ],
      ),
    );
  }
}

class AddInventoryScreen extends StatefulWidget {
  const AddInventoryScreen({super.key});
  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final name = TextEditingController();
  final notes = TextEditingController();
  final qty = TextEditingController(text: '1');
  final tags = <String>{};
  final images = <XFile>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New inventory')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: qty,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notes,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['climbing', 'foreign', 'driving']
                .map(
                  (t) => FilterChip(
                    label: Text(t),
                    selected: tags.contains(t),
                    onSelected: (_) {
                      setState(() {
                        if (tags.contains(t)) {
                          tags.remove(t);
                        } else {
                          tags.add(t);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: images
                .map(
                  (x) => Image.file(
                    File(x.path),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final x = await picker.pickImage(source: ImageSource.camera);
                  if (x != null) setState(() => images.add(x));
                },
                icon: const Icon(Icons.photo_camera),
                label: const Text('Camera'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final xs = await picker.pickMultiImage();
                  if (xs.isNotEmpty) setState(() => images.addAll(xs));
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              final q = int.tryParse(qty.text) ?? 1;
              final item = InventoryItem(
                id: UniqueKey().toString(),
                name: name.text.trim(),
                quantity: q,
                notes: notes.text.trim(),
                missionTypes: tags.toList(),
                images: images.map((e) => e.path.asFile).toList(),
                extraImages: images.skip(1).map((e) => e.path.asFile).toList(),
              );
              Navigator.pop(context, item);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Missions')),
      body: AnimatedBuilder(
        animation: state,
        builder: (_, __) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.missions.length,
          itemBuilder: (_, i) {
            final m = state.missions[i];
            return Card(
              child: ListTile(
                title: Text(m.name),
                subtitle: Text(
                  '${m.types.join(', ')} • ${m.items.fold<int>(0, (a, b) => a + b.count)} items',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => state.activateMission(m),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MissionDetail(mission: m)),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<Mission>(
            context,
            MaterialPageRoute(builder: (_) => const NewMissionScreen()),
          );
          if (created != null) state.addMission(created);
        },
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }
}

class NewMissionScreen extends StatefulWidget {
  const NewMissionScreen({super.key});
  @override
  State<NewMissionScreen> createState() => _NewMissionScreenState();
}

class _NewMissionScreenState extends State<NewMissionScreen> {
  final name = TextEditingController();
  DateTime? start;
  DateTime? end;
  final types = <String>{};
  final items = <MissionEntry>[];
  final notes = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('New mission')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                    );
                    if (d == null) return;
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t == null) return;
                    setState(
                      () => start = DateTime(
                        d.year,
                        d.month,
                        d.day,
                        t.hour,
                        t.minute,
                      ),
                    );
                  },
                  child: Text(start == null ? 'Set start' : start.toString()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                    );
                    if (d == null) return;
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t == null) return;
                    setState(
                      () => end = DateTime(
                        d.year,
                        d.month,
                        d.day,
                        t.hour,
                        t.minute,
                      ),
                    );
                  },
                  child: Text(end == null ? 'Set end' : end.toString()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['climbing', 'foreign', 'driving']
                .map(
                  (t) => FilterChip(
                    label: Text(t),
                    selected: types.contains(t),
                    onSelected: (_) {
                      setState(() {
                        if (types.contains(t)) {
                          types.remove(t);
                        } else {
                          types.add(t);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await Navigator.push<List<MissionEntry>>(
                context,
                MaterialPageRoute(builder: (_) => PickInventoryScreen()),
              );
              if (picked != null) setState(() => items.addAll(picked));
            },
            icon: const Icon(Icons.inventory_2),
            label: const Text('Add inventory'),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (e) => ListTile(
              title: Text(e.item.name),
              subtitle: Text('×${e.count}'),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              final m = Mission(
                id: UniqueKey().toString(),
                name: name.text.trim(),
                start: start,
                end: end,
                types: types.toList(),
                items: items.toList(),
                notes: notes.text.trim(),
                todos: [],
              );
              Navigator.pop(context, m);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class PickInventoryScreen extends StatefulWidget {
  const PickInventoryScreen({super.key});
  @override
  State<PickInventoryScreen> createState() => _PickInventoryScreenState();
}

class _PickInventoryScreenState extends State<PickInventoryScreen> {
  final Map<String, int> counts = {};
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pick items')),
      body: ListView.builder(
        itemCount: state.inventory.length,
        itemBuilder: (_, i) {
          final it = state.inventory[i];
          final c = counts[it.id] ?? 0;
          return ListTile(
            leading: it.images.isNotEmpty
                ? Image.file(
                    it.images.first.toFile(),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.inventory_2),
            title: Text(it.name),
            subtitle: Text('Available: ${it.quantity}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => setState(
                    () => counts[it.id] = (c - 1).clamp(0, it.quantity),
                  ),
                  icon: const Icon(Icons.remove),
                ),
                Text('$c'),
                IconButton(
                  onPressed: () => setState(
                    () => counts[it.id] = (c + 1).clamp(0, it.quantity),
                  ),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final selected = <MissionEntry>[];
          for (final e in counts.entries) {
            if (e.value > 0) {
              final item = state.inventory.firstWhere((it) => it.id == e.key);
              selected.add(MissionEntry(item: item, count: e.value));
            }
          }
          Navigator.pop(context, selected);
        },
        icon: const Icon(Icons.check),
        label: const Text('Add'),
      ),
    );
  }
}

class MissionDetail extends StatefulWidget {
  final Mission mission;
  const MissionDetail({super.key, required this.mission});
  @override
  State<MissionDetail> createState() => _MissionDetailState();
}

class _MissionDetailState extends State<MissionDetail> {
  final todoCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final m = widget.mission;
    return Scaffold(
      appBar: AppBar(title: Text(m.name)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (m.start != null) Text('Start: ${m.start}'),
          if (m.end != null) Text('End: ${m.end}'),
          const SizedBox(height: 8),
          Text('Types: ${m.types.join(', ')}'),
          const SizedBox(height: 12),
          Text('Items', style: Theme.of(context).textTheme.titleMedium),
          ...m.items.asMap().entries.map(
            (entry) => CheckboxListTile(
              value: entry.value.done,
              onChanged: (_) => state.toggleMissionItem(m, entry.key),
              secondary: entry.value.item.images.isNotEmpty
                  ? Image.file(
                      entry.value.item.images.first.toFile(),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.inventory),
              title: Text(
                entry.value.item.name,
                style: TextStyle(
                  decoration: entry.value.done ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text('×${entry.value.count}'),
            ),
          ),
          const SizedBox(height: 12),
          Text('Notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: m.notes),
            maxLines: 4,
            onChanged: (v) => state.updateMissionNotes(m, v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Text('Todos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...m.todos.asMap().entries.map(
            (e) => CheckboxListTile(
              value: e.value.done,
              onChanged: (_) => state.toggleTodo(m, e.key),
              title: Text(e.value.text),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: todoCtrl,
                  decoration: const InputDecoration(
                    hintText: 'New todo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  if (todoCtrl.text.trim().isEmpty) return;
                  state.addTodo(
                    m,
                    TodoItem(text: todoCtrl.text.trim(), done: false),
                  );
                  setState(() => todoCtrl.clear());
                },
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!state.activeMissions.contains(m))
            FilledButton.icon(
              onPressed: () => AppScope.of(context).activateMission(m),
              icon: const Icon(Icons.play_circle),
              label: const Text('Activate'),
            ),
        ],
      ),
    );
  }
}

class MissionItemTodos extends StatefulWidget {
  final Mission mission;
  final MissionEntry entry;
  const MissionItemTodos({
    super.key,
    required this.mission,
    required this.entry,
  });
  @override
  State<MissionItemTodos> createState() => _MissionItemTodosState();
}

class _MissionItemTodosState extends State<MissionItemTodos> {
  final todoCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final m = widget.mission;
    final e = widget.entry;
    return Scaffold(
      appBar: AppBar(title: Text('${e.item.name} todos')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: e.item.images
                .map(
                  (f) => Image.file(
                    f.toFile(),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          ...e.todos.asMap().entries.map(
            (t) => CheckboxListTile(
              value: t.value.done,
              onChanged: (_) => setState(
                () => e.todos[t.key] = t.value.copyWith(done: !t.value.done),
              ),
              title: Text(t.value.text),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: todoCtrl,
                  decoration: const InputDecoration(
                    hintText: 'New todo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  if (todoCtrl.text.trim().isEmpty) return;
                  setState(
                    () => e.todos.add(
                      TodoItem(text: todoCtrl.text.trim(), done: false),
                    ),
                  );
                  todoCtrl.clear();
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActiveMissionsScreen extends StatelessWidget {
  const ActiveMissionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Active missions')),
      body: AnimatedBuilder(
        animation: state,
        builder: (_, __) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.activeMissions.length,
          itemBuilder: (_, i) {
            final m = state.activeMissions[i];
            return Card(
              child: ListTile(
                title: Text(m.name),
                subtitle: Text(
                  m.start == null
                      ? 'No reminder'
                      : 'Reminder set for ${m.start}',
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MissionDetail(mission: m)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle),
                  onPressed: () => state.completeMission(m),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class InventoryItem {
  final String id;
  final String name;
  final int quantity;
  final String notes;
  final List<String> missionTypes;
  final List<FileLike> images;
  final List<FileLike> extraImages;
  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.notes,
    required this.missionTypes,
    required this.images,
    required this.extraImages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'notes': notes,
    'missionTypes': missionTypes,
    'images': images.map((f) => f.path).toList(),
    'extraImages': extraImages.map((f) => f.path).toList(),
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'],
    name: json['name'],
    quantity: json['quantity'],
    notes: json['notes'],
    missionTypes: List<String>.from(json['missionTypes']),
    images: (json['images'] as List).map((path) => FileLike(path)).toList(),
    extraImages: (json['extraImages'] as List).map((path) => FileLike(path)).toList(),
  );
}

class MissionEntry {
  final InventoryItem item;
  final int count;
  final List<TodoItem> todos;
  bool done;
  MissionEntry({required this.item, required this.count, List<TodoItem>? todos, this.done = false})
    : todos = todos ?? [];

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'count': count,
    'todos': todos.map((t) => t.toJson()).toList(),
    'done': done,
  };

  factory MissionEntry.fromJson(Map<String, dynamic> json) => MissionEntry(
    item: InventoryItem.fromJson(json['item']),
    count: json['count'],
    todos: (json['todos'] as List).map((t) => TodoItem.fromJson(t)).toList(),
    done: json['done'],
  );
}

class Mission {
  final String id;
  final String name;
  final DateTime? start;
  final DateTime? end;
  final List<String> types;
  final List<MissionEntry> items;
  final List<TodoItem> todos;
  String notes;
  Mission({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.types,
    required this.items,
    required this.notes,
    required this.todos,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'start': start?.toIso8601String(),
    'end': end?.toIso8601String(),
    'types': types,
    'items': items.map((i) => i.toJson()).toList(),
    'todos': todos.map((t) => t.toJson()).toList(),
    'notes': notes,
  };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    id: json['id'],
    name: json['name'],
    start: json['start'] != null ? DateTime.parse(json['start']) : null,
    end: json['end'] != null ? DateTime.parse(json['end']) : null,
    types: List<String>.from(json['types']),
    items: (json['items'] as List).map((i) => MissionEntry.fromJson(i)).toList(),
    todos: (json['todos'] as List).map((t) => TodoItem.fromJson(t)).toList(),
    notes: json['notes'],
  );
}

class TodoItem {
  final String text;
  final bool done;
  TodoItem({required this.text, required this.done});
  TodoItem copyWith({String? text, bool? done}) =>
      TodoItem(text: text ?? this.text, done: done ?? this.done);

  Map<String, dynamic> toJson() => {
    'text': text,
    'done': done,
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    text: json['text'],
    done: json['done'],
  );
}

extension on String {
  FileLike get asFile => FileLike(this);
}

class FileLike {
  final String path;
  FileLike(this.path);

  File toFile() => File(path);
}

class tz {
  static final local = _Local();
  static TZDateTime from(DateTime dt, _Local _) => TZDateTime(dt);
}

class _Local {}

class TZDateTime {
  final DateTime value;
  TZDateTime(this.value);
}
