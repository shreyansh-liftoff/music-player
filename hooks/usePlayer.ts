import {useCallback, useEffect, useMemo, useState} from 'react';
import {NativeEventEmitter, NativeModules} from 'react-native';

const {AudioModule} = NativeModules;

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
    artwork?: string;
  }
}

const usePlayer = ({sourceUrl, seekInterval = 5, trackInfo, autoPlay = false}: PlayerProps) => {
  const [isLoading, setIsLoading] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [totalDuration, setTotalDuration] = useState(0);
  const eventHandler = useMemo(() => new NativeEventEmitter(AudioModule), []);
  const [currentProgress, setCurrentProgress] = useState(0);
  const [elapsedTime, setCurrentTime] = useState(0);

  const setTrackInfo = useCallback(async() => {
    try {
      await AudioModule.setMediaPlayerInfo(trackInfo?.title, trackInfo?.artist, trackInfo?.artwork);
    } catch (error) {
      console.error('Error setting track info', error);
    }
  }, [trackInfo]);


  useEffect(() => {
    if (currentProgress === 100) {
      setIsPlaying(false);
      stopSound();
    }
  }, [currentProgress]);

  useEffect(() => {
    const progressEventHandler = eventHandler.addListener(
      'onProgressUpdate',
      (event: any) => {
        const {currentTime, progress} = event;
        setCurrentTime(currentTime);
        setCurrentProgress(progress);
      },
    );

    return () => {
      progressEventHandler.remove();
    };
  }, [eventHandler]);

  const getDuration = useCallback(async () => {
    try {
      const duration: number = await new Promise((resolve, reject) => {
        AudioModule.getTotalDuration(sourceUrl, (result: any) => {
          if (result) {
            resolve(result); // Assuming result is an array with the duration at index 0
          } else {
            reject(new Error('Failed to fetch duration.'));
          }
        });
      });
      setTotalDuration(duration);
    } catch (error) {
      console.error('Error getting duration', error);
    }
  }, [sourceUrl]);

  const playSound = useCallback(async () => {
    try {
      setIsLoading(true);
      await AudioModule.play(sourceUrl);
      setIsPlaying(true);
    } catch (error) {
      console.error('Error playing sound', error);
    } finally {
      setIsLoading(false);
    }
  }, [sourceUrl]);

  const pauseSound = () => {
    AudioModule.pause();
    setIsPlaying(false);
  };

  const stopSound = () => {
    AudioModule.stop();
    setIsPlaying(false);
  };

  const onSeekForward = async() => {
    try {
      await AudioModule.seek(seekInterval);
    } catch (error) {
      console.error('Error seeking forward', error);
    }
  };

  const onSeekBackward = async() => {
    try {
      await AudioModule.seek(-seekInterval);
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
    if (trackInfo && totalDuration) {
      setTrackInfo();
    }
  }, [trackInfo, setTrackInfo, totalDuration]);

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
