import React from 'react';
import {View} from 'react-native';
import IconButton, {IconButtonPropsV2} from '../ui/iconButton';

export interface PreviousControlsProps {
  onSeekBackward?: () => void;
  onPlayBack?: () => void;
  showSkip?: boolean;
  showPlayback?: boolean;
  skipBackComponent?: React.ReactNode;
  playBackComponent?: React.ReactNode;
  containerProps?: any;
  iconButtonProps?: IconButtonPropsV2;
  stylesProps?: {
    container?: any;
    iconButton?: any;
  };
}

const PreviousControls = ({
  onSeekBackward,
  onPlayBack,
  skipBackComponent,
  playBackComponent,
  containerProps,
  iconButtonProps,
  showSkip = true,
  showPlayback = true,
  stylesProps,
}: PreviousControlsProps) => {
  const skipBack = () => {
    if (!showSkip) {
      return;
    }
    return (
      <View>
        {skipBackComponent ? (
          skipBackComponent
        ) : (
          <IconButton
            {...iconButtonProps}
            name={iconButtonProps?.name ?? 'play-skip-back-outline'}
            onPress={onPlayBack}
            style={stylesProps?.iconButton}
          />
        )}
      </View>
    );
  };

  const playBack = () => {
    if (!showPlayback) {
      return;
    }
    return (
      <View>
        {playBackComponent ? (
          playBackComponent
        ) : (
          <IconButton
            {...iconButtonProps}
            name={iconButtonProps?.name ?? 'play-back-outline'}
            onPress={onSeekBackward}
            style={iconButtonProps?.style}
          />
        )}
      </View>
    );
  };

  return (
    <View {...containerProps} style={stylesProps?.container}>
      {skipBack()}
      {playBack()}
    </View>
  );
};

export default PreviousControls;
