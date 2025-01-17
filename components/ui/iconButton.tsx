import React from 'react';
import {StyleSheet, View} from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import useColorScheme from '../../hooks/useColorScheme';
import {IconButtonProps} from 'react-native-vector-icons/Icon';

export interface IconButtonPropsV2 extends IconButtonProps {
  key?: string;
  containerStyles?: any;
}

const IconButton = ({key, containerStyles, ...props}: IconButtonPropsV2) => {
  const {iconButtonUnderlayColor: underlayColor, fontColor, backgroundColor: _backgroundColor} = useColorScheme();
  return (
    <View key={key} style={{...styles.container, ...containerStyles}}>
      <Icon.Button
        size={props.size ?? 30}
        color={props?.color ?? fontColor}
        backgroundColor={props?.backgroundColor ?? _backgroundColor}
        underlayColor={props?.underlayColor ?? underlayColor}
        style={{...styles.iconButton, ...props.style}}
        {...props}
      />
    </View>
  );
};

const styles = StyleSheet.create({
    container: {
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        textAlign: 'center',
    },
    iconButton: {
        marginHorizontal: 10,
    },
});

export default IconButton;
