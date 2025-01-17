import React from 'react';
import {View} from 'react-native';
import IconButton, {IconButtonPropsV2} from '../ui/iconButton';

export interface NextControlsProps {
  onNext?: () => void;
  onSeekForward?: () => void;
  showNext?: boolean;
  showSkipFoward?: boolean;
  nextComponent?: React.ReactNode;
  skipForwardComponent?: React.ReactNode;
  containerProps?: any;
  iconButtonProps?: IconButtonPropsV2;
  styleProps?: {
    container?: any;
    iconButton?: any;
  };
}

const NextControls = ({
  onNext,
  onSeekForward,
  nextComponent,
  skipForwardComponent,
  containerProps,
  iconButtonProps,
  showNext = true,
  showSkipFoward = true,
  styleProps,
}: NextControlsProps) => {
  const skipNext = () => {
    if (!showNext) {
      return;
    }
    return (
      <View>
        {nextComponent ? (
          nextComponent
        ) : (
          <IconButton
            {...iconButtonProps}
            name={iconButtonProps?.name ?? 'play-forward-outline'}
            onPress={onSeekForward}
            style={styleProps?.iconButton}
          />
        )}
      </View>
    );
  };

  const playForward = () => {
    if (!showSkipFoward) {
      return;
    }
    return (
      <View>
        {skipForwardComponent ? (
          skipForwardComponent
        ) : (
          <IconButton
            {...iconButtonProps}
            name={iconButtonProps?.name ?? 'play-skip-forward-outline'}
            onPress={onNext}
            style={styleProps?.iconButton}
          />
        )}
      </View>
    );
  };

  return (
    <View {...containerProps} style={styleProps?.container}>
      {skipNext()}
      {playForward()}
    </View>
  );
};

export default NextControls;
