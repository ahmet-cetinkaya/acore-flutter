# Sounds

## Overview

The sounds module provides a cross-platform abstraction layer for audio playback in Flutter applications. It offers a simple, consistent API for playing sound effects and audio files while handling platform-specific implementations such as audio focus management, volume control, and playback state management.

## Features

- 🎵 **Cross-Platform Audio** - Works on Android, iOS, and Desktop platforms
- 🎯 **Simple API** - Minimal interface with essential playback controls
- 🔊 **Audio Focus Management** - Automatic audio focus handling for better user experience
- 🎛️ **Volume Control** - Precise volume adjustment support
- 🔄 **Loop Support** - Enable audio looping for background music or repeated effects
- ⏸️ **Playback Controls** - Play, pause, resume, and stop functionality
- 🧹 **Resource Management** - Proper cleanup and disposal of audio resources

## Core Interface

### ISoundPlayer

```dart
abstract class ISoundPlayer {
  /// Play audio file with optional audio focus and volume control
  void play(String path, {bool requestAudioFocus = true, double? volume});

  /// Stop current playback
  void stop();

  /// Pause current playback
  void pause();

  /// Resume paused playback
  void resume();

  /// Set volume level (0.0 to 1.0)
  void setVolume(double volume);

  /// Enable or disable audio looping
  void setLoop(bool loop);

  /// Dispose resources and cleanup
  void dispose();
}
```

## Usage Examples

### Basic Sound Playback

```dart
class NotificationManager {
  final ISoundPlayer _soundPlayer;

  NotificationManager(this._soundPlayer);

  /// Play notification sound
  void playNotificationSound() {
    _soundPlayer.play('assets/sounds/notification.mp3');
  }

  /// Play success sound
  void playSuccessSound() {
    _soundPlayer.play('assets/sounds/success.wav');
  }

  /// Play error sound with reduced volume
  void playErrorSound() {
    _soundPlayer.play(
      'assets/sounds/error.mp3',
      volume: 0.5, // 50% volume
    );
  }

  /// Cleanup resources
  void dispose() {
    _soundPlayer.dispose();
  }
}
```

### Background Music Player

```dart
class BackgroundMusicPlayer {
  final ISoundPlayer _soundPlayer;
  String? _currentTrack;

  BackgroundMusicPlayer(this._soundPlayer);

  /// Play background music with looping
  void playBackgroundMusic(String trackPath) {
    // Stop current track if playing
    if (_currentTrack != null) {
      _soundPlayer.stop();
    }

    _currentTrack = trackPath;
    _soundPlayer.play(
      trackPath,
      requestAudioFocus: false, // Don't interrupt other audio
      volume: 0.3, // Lower volume for background music
    );
    _soundPlayer.setLoop(true); // Enable looping
  }

  /// Adjust background music volume
  void setMusicVolume(double volume) {
    _soundPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Pause background music
  void pauseMusic() {
    _soundPlayer.pause();
  }

  /// Resume background music
  void resumeMusic() {
    _soundPlayer.resume();
  }

  /// Stop background music
  void stopMusic() {
    _soundPlayer.stop();
    _currentTrack = null;
  }

  /// Fade out music
  void fadeOutMusic({Duration duration = const Duration(seconds: 2)}) {
    if (_currentTrack == null) return;

    // Simple fade implementation
    final steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;
    var currentStep = 0;

    Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
      currentStep++;
      final newVolume = (1.0 - currentStep / steps) * 0.3;
      _soundPlayer.setVolume(newVolume);

      if (currentStep >= steps) {
        timer.cancel();
        stopMusic();
      }
    });
  }

  void dispose() {
    stopMusic();
    _soundPlayer.dispose();
  }
}
```

### Game Sound Effects Manager

```dart
class GameSoundManager {
  final ISoundPlayer _soundPlayer;
  final Map<GameSound, String> _soundPaths = {};
  bool _isMuted = false;
  double _effectsVolume = 1.0;

  GameSoundManager(this._soundPlayer) {
    _initializeSoundPaths();
  }

  void _initializeSoundPaths() {
    _soundPaths[GameSound.jump] = 'assets/sounds/jump.wav';
    _soundPaths[GameSound.collect] = 'assets/sounds/collect.mp3';
    _soundPaths[GameSound.hit] = 'assets/sounds/hit.wav';
    _soundPaths[GameSound.powerUp] = 'assets/sounds/powerup.mp3';
    _soundPaths[GameSound.gameOver] = 'assets/sounds/gameover.mp3';
  }

  /// Play specific game sound
  void playSound(GameSound sound, {double? volume}) {
    if (_isMuted) return;

    final soundPath = _soundPaths[sound];
    if (soundPath == null) return;

    _soundPlayer.play(
      soundPath,
      volume: (volume ?? _effectsVolume).clamp(0.0, 1.0),
      requestAudioFocus: false,
    );
  }

  /// Toggle mute state
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _soundPlayer.setVolume(0.0);
    } else {
      _soundPlayer.setVolume(_effectsVolume);
    }
  }

  /// Set effects volume
  void setEffectsVolume(double volume) {
    _effectsVolume = volume.clamp(0.0, 1.0);
    if (!_isMuted) {
      _soundPlayer.setVolume(_effectsVolume);
    }
  }

  /// Play jump sound
  void playJumpSound() => playSound(GameSound.jump);

  /// Play collection sound
  void playCollectSound() => playSound(GameSound.collect);

  /// Play hit sound
  void playHitSound() => playSound(GameSound.hit);

  /// Play power-up sound
  void playPowerUpSound() => playSound(GameSound.powerUp);

  /// Play game over sound (doesn't respect mute)
  void playGameOverSound() {
    final soundPath = _soundPaths[GameSound.gameOver];
    if (soundPath != null) {
      _soundPlayer.play(soundPath, volume: 1.0, requestAudioFocus: true);
    }
  }

  void dispose() {
    _soundPlayer.dispose();
  }
}

enum GameSound {
  jump,
  collect,
  hit,
  powerUp,
  gameOver,
}
```

### Interactive UI Sounds

```dart
class UISoundManager {
  final ISoundPlayer _soundPlayer;
  final Map<UISound, String> _soundPaths = {};
  final SettingsService _settings;
  Timer? _debounceTimer;

  UISoundManager(this._soundPlayer, this._settings) {
    _initializeSoundPaths();
  }

  void _initializeSoundPaths() {
    _soundPaths[UISound.buttonClick] = 'assets/sounds/click.wav';
    _soundPaths[UISound.buttonPress] = 'assets/sounds/press.mp3';
    _soundPaths[UISound.toggleOn] = 'assets/sounds/toggle_on.wav';
    _soundPaths[UISound.toggleOff] = 'assets/sounds/toggle_off.wav';
    _soundPaths[UISound.notification] = 'assets/sounds/notification.mp3';
    _soundPaths[UISound.success] = 'assets/sounds/success.wav';
    _soundPaths[UISound.error] = 'assets/sounds/error.mp3';
    _soundPaths[UISound.swipe] = 'assets/sounds/swipe.wav';
  }

  /// Play UI sound with debouncing to prevent audio spam
  void playUISound(UISound sound, {bool allowOverlap = false}) {
    if (!_settings.soundEnabled) return;

    // Prevent rapid sound playback
    if (!allowOverlap && _debounceTimer?.isActive == true) {
      return;
    }

    final soundPath = _soundPaths[sound];
    if (soundPath == null) return;

    _soundPlayer.play(
      soundPath,
      volume: _settings.soundVolume,
      requestAudioFocus: false,
    );

    // Set debounce timer
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      _debounceTimer = null;
    });
  }

  /// Enhanced button click with haptic feedback
  void playButtonClick() {
    playUISound(UISound.buttonClick);
    HapticFeedback.lightImpact(); // If haptics are available
  }

  /// Play toggle sound based on state
  void playToggleSound(bool isOn) {
    playUISound(isOn ? UISound.toggleOn : UISound.toggleOff);
  }

  /// Play swipe sound for navigation
  void playSwipeSound() {
    playUISound(UISound.swipe, allowOverlap: true); // Allow swipes to overlap
  }

  /// Play notification sound with priority
  void playNotificationSound() {
    playUISound(UISound.notification);
  }

  void dispose() {
    _debounceTimer?.cancel();
    _soundPlayer.dispose();
  }
}

enum UISound {
  buttonClick,
  buttonPress,
  toggleOn,
  toggleOff,
  notification,
  success,
  error,
  swipe,
}
```

### Audio Focus Management

```dart
class AudioFocusManager {
  final ISoundPlayer _soundPlayer;
  bool _hasAudioFocus = false;

  AudioFocusManager(this._soundPlayer) {
    // Listen for audio focus changes
    _setupAudioFocusListener();
  }

  void _setupAudioFocusListener() {
    // Platform-specific audio focus handling
    // This would need platform-specific implementation
  }

  /// Request audio focus for important sounds
  Future<bool> requestAudioFocus() async {
    if (_hasAudioFocus) return true;

    try {
      // Platform-specific audio focus request
      final gained = await _platformRequestAudioFocus();
      _hasAudioFocus = gained;

      if (gained) {
        _soundPlayer.setVolume(1.0);
      }

      return gained;
    } catch (e) {
      return false;
    }
  }

  /// Release audio focus
  void releaseAudioFocus() {
    if (!_hasAudioFocus) return;

    _platformReleaseAudioFocus();
    _hasAudioFocus = false;
  }

  /// Play sound with automatic audio focus management
  void playWithAudioFocus(String soundPath, {bool requestFocus = true}) {
    if (requestFocus) {
      requestAudioFocus().then((hasFocus) {
        if (hasFocus) {
          _soundPlayer.play(soundPath);
        }
      });
    } else {
      _soundPlayer.play(soundPath, requestAudioFocus: false);
    }
  }

  /// Handle audio focus loss
  void onAudioFocusLoss() {
    _hasAudioFocus = false;
    _soundPlayer.pause();
  }

  /// Handle temporary audio focus loss
  void onAudioFocusLossTransient() {
    _soundPlayer.pause();
  }

  /// Handle audio focus gain
  void onAudioFocusGain() {
    _hasAudioFocus = true;
    _soundPlayer.resume();
  }

  Future<bool> _platformRequestAudioFocus() async {
    // Platform-specific implementation
    return true;
  }

  void _platformReleaseAudioFocus() {
    // Platform-specific implementation
  }

  void dispose() {
    releaseAudioFocus();
    _soundPlayer.dispose();
  }
}
```

### Sound Queue Manager

```dart
class SoundQueueManager {
  final ISoundPlayer _soundPlayer;
  final Queue<SoundQueueItem> _queue = Queue();
  bool _isPlaying = false;

  SoundQueueManager(this._soundPlayer) {
    _soundPlayer.play(''); // Initialize player
  }

  /// Add sound to queue
  void addToQueue(String soundPath, {double? volume, bool requestFocus = true}) {
    _queue.add(SoundQueueItem(
      soundPath: soundPath,
      volume: volume,
      requestFocus: requestFocus,
    ));

    _processQueue();
  }

  /// Add multiple sounds to queue
  void addToQueueSequentially(List<String> soundPaths, {double? volume}) {
    for (final path in soundPaths) {
      addToQueue(path, volume: volume);
    }
  }

  /// Process next sound in queue
  void _processQueue() {
    if (_isPlaying || _queue.isEmpty) return;

    _isPlaying = true;
    final nextSound = _queue.removeFirst();

    // Play sound and set up completion callback
    _soundPlayer.play(
      nextSound.soundPath,
      volume: nextSound.volume,
      requestAudioFocus: nextSound.requestFocus,
    );

    // In a real implementation, you'd need a way to detect when sound finishes
    // This could be done through platform-specific callbacks
    Timer(const Duration(milliseconds: 500), () { // Estimate duration
      _isPlaying = false;
      _processQueue(); // Process next in queue
    });
  }

  /// Clear the sound queue
  void clearQueue() {
    _queue.clear();
  }

  /// Stop current playback and clear queue
  void stopAll() {
    _soundPlayer.stop();
    _queue.clear();
    _isPlaying = false;
  }

  /// Get queue length
  int get queueLength => _queue.length;

  void dispose() {
    stopAll();
    _soundPlayer.dispose();
  }
}

class SoundQueueItem {
  final String soundPath;
  final double? volume;
  final bool requestFocus;

  SoundQueueItem({
    required this.soundPath,
    this.volume,
    this.requestFocus = true,
  });
}
```

## Platform Implementations

### Android Implementation

```dart
class AndroidSoundPlayer implements ISoundPlayer {
  static const MethodChannel _channel = MethodChannel('acore/sound_player');
  bool _isInitialized = false;
  String? _currentSound;

  @override
  void play(String path, {bool requestAudioFocus = true, double? volume}) async {
    if (!_isInitialized) {
      await _initialize();
    }

    _currentSound = path;
    await _channel.invokeMethod('play', {
      'path': path,
      'requestAudioFocus': requestAudioFocus,
      'volume': volume ?? 1.0,
    });
  }

  @override
  void stop() async {
    await _channel.invokeMethod('stop');
    _currentSound = null;
  }

  @override
  void pause() async {
    await _channel.invokeMethod('pause');
  }

  @override
  void resume() async {
    await _channel.invokeMethod('resume');
  }

  @override
  void setVolume(double volume) async {
    await _channel.invokeMethod('setVolume', {'volume': volume});
  }

  @override
  void setLoop(bool loop) async {
    await _channel.invokeMethod('setLoop', {'loop': loop});
  }

  @override
  void dispose() async {
    await _channel.invokeMethod('dispose');
    _isInitialized = false;
  }

  Future<void> _initialize() async {
    await _channel.invokeMethod('initialize');
    _isInitialized = true;
  }
}
```

### Desktop Implementation

```dart
class DesktopSoundPlayer implements ISoundPlayer {
  late AudioPlayer _player;
  bool _isInitialized = false;

  @override
  void play(String path, {bool requestAudioFocus = true, double? volume}) async {
    if (!_isInitialized) {
      await _initialize();
    }

    if (volume != null) {
      _player.setVolume(volume);
    }

    await _player.play(DeviceFileSource(path));
  }

  @override
  void stop() async {
    await _player.stop();
  }

  @override
  void pause() async {
    await _player.pause();
  }

  @override
  void resume() async {
    await _player.resume();
  }

  @override
  void setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  @override
  void setLoop(bool loop) async {
    await _player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
  }

  @override
  void dispose() async {
    await _player.dispose();
    _isInitialized = false;
  }

  Future<void> _initialize() async {
    _player = AudioPlayer();
    _isInitialized = true;
  }
}
```

## Testing Sound Management

### Mock Implementation for Testing

```dart
class MockSoundPlayer implements ISoundPlayer {
  String? _currentSound;
  double _currentVolume = 1.0;
  bool _isLooping = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  final List<String> _playHistory = [];

  String? get currentSound => _currentSound;
  double get currentVolume => _currentVolume;
  bool get isLooping => _isLooping;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  List<String> get playHistory => List.unmodifiable(_playHistory);

  @override
  void play(String path, {bool requestAudioFocus = true, double? volume}) {
    _currentSound = path;
    _currentVolume = volume ?? 1.0;
    _isPlaying = true;
    _isPaused = false;
    _playHistory.add(path);
  }

  @override
  void stop() {
    _currentSound = null;
    _isPlaying = false;
    _isPaused = false;
  }

  @override
  void pause() {
    _isPaused = true;
  }

  @override
  void resume() {
    if (_isPlaying) {
      _isPaused = false;
    }
  }

  @override
  void setVolume(double volume) {
    _currentVolume = volume;
  }

  @override
  void setLoop(bool loop) {
    _isLooping = loop;
  }

  @override
  void dispose() {
    _currentSound = null;
    _isPlaying = false;
    _isPaused = false;
    _playHistory.clear();
  }

  // Test helper methods
  void simulatePlaybackComplete() {
    _currentSound = null;
    _isPlaying = false;
    _isPaused = false;
  }
}
```

### Unit Testing Sound Managers

```dart
void main() {
  group('GameSoundManager Tests', () {
    late GameSoundManager soundManager;
    late MockSoundPlayer mockPlayer;

    setUp(() {
      mockPlayer = MockSoundPlayer();
      soundManager = GameSoundManager(mockPlayer);
    });

    test('should play jump sound with correct parameters', () {
      // Act
      soundManager.playJumpSound();

      // Assert
      expect(mockPlayer.currentSound, equals('assets/sounds/jump.wav'));
      expect(mockPlayer.isPlaying, isTrue);
      expect(mockPlayer.currentVolume, equals(1.0));
    });

    test('should respect mute state', () {
      // Arrange
      soundManager.toggleMute(); // Mute

      // Act
      soundManager.playCollectSound();

      // Assert
      expect(mockPlayer.isPlaying, isFalse);
      expect(mockPlayer.currentSound, isNull);
    });

    test('should adjust effects volume', () {
      // Arrange
      soundManager.setEffectsVolume(0.5);

      // Act
      soundManager.playHitSound();

      // Assert
      expect(mockPlayer.currentVolume, equals(0.5));
    });

    test('should play game over sound even when muted', () {
      // Arrange
      soundManager.toggleMute(); // Mute

      // Act
      soundManager.playGameOverSound();

      // Assert
      expect(mockPlayer.currentSound, equals('assets/sounds/gameover.mp3'));
      expect(mockPlayer.isPlaying, isTrue);
    });
  });
}
```

## Best Practices

### 1. Resource Management

```dart
// ✅ Good: Proper cleanup
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late UISoundManager _soundManager;

  @override
  void initState() {
    super.initState();
    final soundPlayer = GetIt.instance<ISoundPlayer>();
    _soundManager = UISoundManager(soundPlayer, GetIt.instance<SettingsService>());
  }

  @override
  void dispose() {
    _soundManager.dispose();
    super.dispose();
  }
}
```

### 2. Prevent Audio Spam

```dart
// ✅ Good: Debounce rapid sounds
void playClickSound() {
  if (_lastClickTime != null &&
      DateTime.now().difference(_lastClickTime!) < const Duration(milliseconds: 100)) {
    return; // Skip if too recent
  }

  _soundPlayer.play('click.wav');
  _lastClickTime = DateTime.now();
}
```

### 3. Respect User Settings

```dart
// ✅ Good: Check settings before playing
void playNotificationSound() {
  if (!_settingsService.soundEnabled) return;

  _soundPlayer.play(
    'notification.mp3',
    volume: _settingsService.notificationVolume,
  );
}
```

### 4. Handle Platform Differences

```dart
// ✅ Good: Platform-specific audio focus
void playImportantSound(String soundPath) {
  if (Platform.isAndroid) {
    _soundPlayer.play(soundPath, requestAudioFocus: true);
  } else {
    _soundPlayer.play(soundPath, requestAudioFocus: false);
  }
}
```

## Performance Considerations

### Audio Performance Tips

1. **Load Sounds Early**: Preload frequently used sounds
2. **Use Efficient Formats**: Use compressed formats like MP3 for longer sounds
3. **Limit Concurrent Sounds**: Avoid playing too many sounds simultaneously
4. **Pool Audio Players**: Reuse player instances instead of creating new ones

```dart
class SoundPool {
  final Map<String, ISoundPlayer> _players = {};
  final Queue<ISoundPlayer> _availablePlayers = Queue();

  ISoundPlayer getPlayer(String soundPath) {
    if (_availablePlayers.isNotEmpty) {
      return _availablePlayers.removeFirst();
    }

    return _players.putIfAbsent(
      soundPath,
      () => SoundPlayerFactory.create(),
    );
  }

  void returnPlayer(ISoundPlayer player) {
    player.stop();
    _availablePlayers.add(player);
  }
}
```

---

**Related Documentation**

- [File Services](../file/README.md)
- [Dependency Injection](../dependency_injection/README.md)
- [Error Handling](../errors/README.md)
