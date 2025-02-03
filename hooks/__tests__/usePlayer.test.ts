import { renderHook, act } from '@testing-library/react-hooks';
import { NativeModules, Platform } from 'react-native';
import usePlayer from '../usePlayer';

const { AudioModule, AudioEventModule } = NativeModules;

jest.mock('react-native', () => {
  const actualReactNative = jest.requireActual('react-native');
  return {
    ...actualReactNative,
    NativeModules: {
      ...actualReactNative.NativeModules,
      AudioModule: {
        playAudio: jest.fn(),
        downloadAndPlayAudio: jest.fn(),
        pauseAudio: jest.fn(),
        stopAudio: jest.fn(),
        getTotalDuration: jest.fn(),
        seek: jest.fn(),
      },
      AudioEventModule: {
        addListener: jest.fn(),
        removeListeners: jest.fn(),
      },
      SettingsManager: {
        settings: {
          AppleLocale: 'en_US',
          AppleLanguages: ['en'],
        },
      },
      // Mocking Android-specific SettingsManager
      Settings: {
        get: jest.fn().mockReturnValue({
          locale: 'en_US',
        }),
      },
    },
    Platform: {
      ...actualReactNative.Platform,
      OS: 'android',
    },
  };
});

describe('usePlayer', () => {
  const sourceUrl = 'https://example.com/audio.mp3';
  const trackInfo = {
    title: 'Test Title',
    artist: 'Test Artist',
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should initialize with default values', () => {
    const { result } = renderHook(() => usePlayer({ sourceUrl }));

    expect(result.current.isLoading).toBe(false);
    expect(result.current.isPlaying).toBe(false);
  });

  it('should play audio on playSound call (Android)', async () => {
    Platform.OS = 'android';
    const { result } = renderHook(() => usePlayer({ sourceUrl, trackInfo }));

    await act(async () => {
      await result.current.playSound();
    });

    expect(AudioModule.playAudio).toHaveBeenCalledWith(sourceUrl, trackInfo);
    expect(result.current.isPlaying).toBe(true);
  });

  it('should play audio on playSound call (iOS)', async () => {
    Platform.OS = 'ios';
    const { result } = renderHook(() => usePlayer({ sourceUrl, trackInfo }));

    await act(async () => {
      await result.current.playSound();
    });

    expect(AudioModule.downloadAndPlayAudio).toHaveBeenCalledWith(sourceUrl, trackInfo);
    expect(result.current.isPlaying).toBe(true);
  });

  it('should pause audio on pauseSound call', () => {
    const { result } = renderHook(() => usePlayer({ sourceUrl }));

    act(() => {
      result.current.pauseSound();
    });

    expect(AudioModule.pauseAudio).toHaveBeenCalled();
    expect(result.current.isPlaying).toBe(false);
  });

  it('should stop audio on stopSound call', () => {
    const { result } = renderHook(() => usePlayer({ sourceUrl }));

    act(() => {
      result.current.stopSound();
    });

    expect(AudioModule.stopAudio).toHaveBeenCalled();
    expect(result.current.isPlaying).toBe(false);
  });

  it('should handle loading state correctly', async () => {
    const { result } = renderHook(() => usePlayer({ sourceUrl, trackInfo }));

    await act(async () => {
      const playPromise = result.current.playSound();
      expect(result.current.isLoading).toBe(true);
      await playPromise;
    });

    expect(result.current.isLoading).toBe(false);
  });

  it('should get total duration', async () => {
    const duration = 300;
    AudioModule.getTotalDuration.mockResolvedValue(duration);
    const { result } = renderHook(() => usePlayer({ sourceUrl }));

    await act(async () => {
      await result.current.totalDuration;
    });

    expect(AudioModule.getTotalDuration).toHaveBeenCalledWith(sourceUrl);
    expect(result.current.totalDuration).toBe(duration);
  });

  it('should auto play when autoPlay is true', async () => {
    const { result } = renderHook(() => usePlayer({ sourceUrl, autoPlay: true, trackInfo }));

    await act(async () => {
      // Simulate the effect running
    });

    expect(AudioModule.playAudio).toHaveBeenCalledWith(sourceUrl, trackInfo);
    expect(result.current.isPlaying).toBe(true);
  });

  it('should call onProgress callback with correct progress', async () => {
    const onProgress = jest.fn();
    renderHook(() => usePlayer({ sourceUrl, onProgress }));

    // Simulate progress update
    act(() => {
      AudioEventModule.addListener.mock.calls[0][1]({ progress: 0.5 });
    });

    expect(onProgress).toHaveBeenCalledWith(0.5);
  });

  it('should call onEnd callback when playback ends', async () => {
    const onEnd = jest.fn();
    renderHook(() => usePlayer({ sourceUrl, onEnd }));

    // Simulate playback end
    act(() => {
      AudioEventModule.addListener.mock.calls[1][1]();
    });

    expect(onEnd).toHaveBeenCalled();
  });

  it('should seek to the correct position', async () => {
    const { result } = renderHook(() => usePlayer({ sourceUrl }));

    await act(async () => {
      await result.current.seek(30);
    });

    expect(AudioModule.seek).toHaveBeenCalledWith(30);
  });

  it('should handle errors correctly', async () => {
    const error = new Error('Test error');
    AudioModule.playAudio.mockRejectedValue(error);
    const { result } = renderHook(() => usePlayer({ sourceUrl, trackInfo }));

    await act(async () => {
      await result.current.playSound();
    });

    expect(result.current.isLoading).toBe(false);
    expect(result.current.isPlaying).toBe(false);
    expect(console.error).toHaveBeenCalledWith('Error playing sound', error);
  });
});
