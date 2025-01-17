import React from 'react';
import {useMemo} from 'react';
import {StyleSheet, Text, View} from 'react-native';
import {convertSecondsToTimeFormat} from '../../utils/utils';
import ProgressBar from './progressIndicatior';

export interface AudioPlayerDurationProps {
  totalDuration: number;
  progressIndicator?: React.ReactNode;
  indicatorColor?: string;
  indicatorHeight?: number;
  currentDuration: number;
  progress: number;
}

const AudioPlayerDuration = ({
  totalDuration = 0,
  currentDuration = 0,
  progress = 0,
}: AudioPlayerDurationProps) => {
  const formattedTotalDuration = useMemo(() => {
    return convertSecondsToTimeFormat(totalDuration);
  }, [totalDuration]);

  const formattedDuration = useMemo(() => {
    return convertSecondsToTimeFormat(currentDuration);
  }, [currentDuration]);

  const progressValue = useMemo(() => {
    return (progress / 100);
  }, [progress]);

  return (
    <View style={styles.container}>
      <View>
        <Text style={styles.durationText}>{`${formattedDuration}`}</Text>
      </View>
      <ProgressBar progress={progressValue} />
      <View>
        <Text style={styles.durationText}>{`${formattedTotalDuration}`}</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    width: '100%',
    flexDirection: 'row',
    justifyContent: 'space-evenly',
    alignItems: 'center',
    marginHorizontal: 'auto',
    marginVertical: 20,
    overflow: 'hidden',
    flexGrow: 1,
    gap: 5,
  },
  durationText: {
    fontSize: 18,
    fontWeight: 'bold',
  },
});

export default AudioPlayerDuration;
