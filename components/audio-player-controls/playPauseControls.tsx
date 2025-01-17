import React from 'react';
import {ActivityIndicator, View} from 'react-native';
import IconButton, { IconButtonPropsV2 } from '../ui/iconButton';

export interface PlayPauseControlsProps {
  onPlay?: () => void;
  onPause?: () => void;
  isPlaying?: boolean;
  showPlay?: boolean;
  showPause?: boolean;
  playComponent?: React.ReactNode;
  pauseComponent?: React.ReactNode;
  containerProps?: any;
  iconButtonProps?: IconButtonPropsV2;
  isReadOnly?: boolean;
  autoPlay?: boolean;
  isLoading?: boolean;
  loadingIndicator?: React.ReactNode;
  stylesProps?: {
    container?: any;
    iconButton?: any;
  };
}

const PlayPauseControls = ({
  isLoading,
  onPlay,
  onPause,
  playComponent,
  pauseComponent,
  containerProps,
  iconButtonProps,
  showPlay = true,
  showPause = true,
  stylesProps,
  isPlaying,
  loadingIndicator,
}: PlayPauseControlsProps) => {

  const loading = () => {
    if(!isLoading) {
      return;
    }
    return (
      <View>
        {
          loadingIndicator ? (
            loadingIndicator
          ) : (
            <ActivityIndicator />
          )
        }
      </View>
    );
  };


  const play = () => {
    if (!showPlay) {
      return;
    }
    return (
      <View>
        {playComponent ? (
          playComponent
        ) : (
          <IconButton
            {...iconButtonProps}
            name={iconButtonProps?.name ?? 'play-outline'}
            onPress={onPlay}
            style={stylesProps?.iconButton}
          />
        )}
      </View>
    );
  };

  const pause = () => {
    if (!showPause) {
      return;
    }
    return (
      <View>
        {pauseComponent ? (
          pauseComponent
        ) : (
          <IconButton
            {...iconButtonProps}
            name={iconButtonProps?.name ?? 'pause-outline'}
            onPress={onPause}
            style={stylesProps?.iconButton}
          />
        )}
      </View>
    );
  };
  return (
    <View {...containerProps} style={stylesProps?.container}>
      {loading()}
      {(isPlaying && !isLoading) ? pause() : play()}
    </View>
  );
};

export default PlayPauseControls;
