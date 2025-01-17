import React from 'react';
import {View, StyleSheet} from 'react-native';

const ProgressBar = ({
  progress,
  color = '#6200ee',
  height = 10,
}: {
  progress: number;
  color?: string;
  height?: number;
}) => {
  // Ensure progress is clamped between 0 and 1
  const clampedProgress = Math.min(Math.max(progress, 0), 1);

  return (
    <View style={[styles.container, {height}]}>
      <View
        style={[
          styles.filledBar,
          {width: `${clampedProgress * 100}%`, backgroundColor: color},
        ]}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    width: '60%',
    backgroundColor: '#e0e0e0',
    borderRadius: 5,
    overflow: 'hidden',
  },
  filledBar: {
    height: '100%',
    borderRadius: 5,
  },
});

export default ProgressBar;
