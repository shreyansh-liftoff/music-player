import {useCallback, useEffect, useMemo, useState} from 'react';
import {DeviceEventEmitter, NativeEventEmitter, NativeModules, Platform} from 'react-native';

const {AudioModule, AudioEventModule} = NativeModules;

export interface PlayerProps {
  sourceUrl?: string;
  file?: File;
  autoPlay?: boolean;
  seekInterval?: number;
  onEnd?: () => void;
  onProgress?: (progress: number) => void;
  trackInfo?: {
    title: string;
    artist: string;
    album?: string;
    artwork?: string;
  };
}

const usePlayer = ({
  sourceUrl,
  seekInterval = 5,
  trackInfo,
  autoPlay = false,
}: PlayerProps) => {
  const [isLoading, setIsLoading] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [totalDuration, setTotalDuration] = useState(0);
  const platform = Platform.OS;
  const eventHandler = useMemo(
    () => platform === 'android' ? DeviceEventEmitter :  new NativeEventEmitter(AudioEventModule),
    [platform],
  );
  const [currentProgress, setCurrentProgress] = useState(0);
  const [elapsedTime, setCurrentTime] = useState(0);

  useEffect(() => {
    if (currentProgress === 100) {
      setIsPlaying(false);
      stopSound();
    }
  }, [currentProgress]);

  useEffect(() => {
    const progressEventHandler = eventHandler.addListener(
      'onAudioProgress',
      (event: any) => {
        console.log('Progress event', event);
        const {currentTime, progress} = event;
        setCurrentTime(currentTime);
        setCurrentProgress(progress * 100);
      },
    );

    return () => {
      progressEventHandler.remove();
    };
  }, [eventHandler]);

  useEffect(() => {
    const stateEventHandler = eventHandler.addListener(
      'onAudioStateChange',
      (event: any) => {
        const {state} = event;
        setIsPlaying(state === 'PLAYING');
      },
    );

    return () => {
      stateEventHandler.remove();
    };
  }, [eventHandler]);

  const getDuration = useCallback(async () => {
    try {
      const duration: number = await AudioModule.getTotalDuration(sourceUrl);
      console.log('Duration', duration);
      setTotalDuration(duration);
    } catch (error) {
      console.error('Error getting duration', error);
    }
  }, [sourceUrl]);

  const playSound = useCallback(async () => {
    try {
      setIsLoading(true);
      await AudioModule?.[platform === 'android' ? 'playAudio' : 'downloadAndPlayAudio'](sourceUrl, trackInfo);
      setIsPlaying(true);
    } catch (error) {
      console.error('Error playing sound', error);
    } finally {
      setIsLoading(false);
    }
  }, [platform, sourceUrl, trackInfo]);

  const pauseSound = () => {
    AudioModule.pauseAudio();
    setIsPlaying(false);
  };

  const stopSound = () => {
    AudioModule.stopAudio();
    setIsPlaying(false);
  };

  const onSeekForward = async () => {
    try {
      const seekTo = elapsedTime + seekInterval > totalDuration ? totalDuration : elapsedTime + seekInterval;
      console.log('Seeking forward to', seekTo);
      await AudioModule.seek(seekTo);
    } catch (error) {
      console.error('Error seeking forward', error);
    }
  };

  const onSeekBackward = async () => {
    try {
      const seekTo = elapsedTime - seekInterval < 0 ? 0 : elapsedTime - seekInterval;
      console.log('Seeking backward to', seekTo);
      await AudioModule.seek(seekTo);
    } catch (error) {
      console.error('Error seeking backward', error);
    }
  };

  useEffect(() => {
    if (autoPlay) {
      playSound();
    }
  }, [autoPlay, playSound]);

  useEffect(() => {
    getDuration();
  }, [getDuration]);

  return {
    playSound,
    pauseSound,
    stopSound,
    isLoading,
    isPlaying,
    totalDuration,
    progress: currentProgress,
    elapsedTime,
    onSeekForward,
    onSeekBackward,
  };
};

export default usePlayer;
