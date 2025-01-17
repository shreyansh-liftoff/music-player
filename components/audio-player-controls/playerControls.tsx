import React from 'react';
import {StyleSheet, View} from 'react-native';
import PreviousControls, { PreviousControlsProps } from './previousControls';
import PlayPauseControls, { PlayPauseControlsProps } from './playPauseControls';
import NextControls, { NextControlsProps } from './nextControls';

export interface PlayerControlsProps extends PlayPauseControlsProps, NextControlsProps, PreviousControlsProps {}

const PlayerControls = (props: PlayerControlsProps) => {
    const styleProps = {container: styles.container, iconButton: styles.iconButton};
  return (
    <View style={styles.container}>
      <PreviousControls {...props} stylesProps={styleProps} />
      <PlayPauseControls {...props} stylesProps={styleProps} />
      <NextControls {...props} onSeekForward={props?.onSeekForward} styleProps={styleProps} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    textAlign: 'center',
    marginHorizontal: 'auto',
  },
  iconButton: {
    padding: 10,
    color: 'black',
  },
});

export default PlayerControls;
