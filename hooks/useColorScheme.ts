import {useColorScheme as useColorSchemeRN} from 'react-native';
import { ColorPalette } from '../theme/colorPalette';

const useColorScheme = () => {
  const isDarkMode = useColorSchemeRN() === 'dark';
  const backgroundColor = isDarkMode ? ColorPalette.dark : ColorPalette.transparent;
  const fontColor = isDarkMode ? ColorPalette.light : ColorPalette.dark;
  const iconButtonUnderlayColor = ColorPalette.light;

  const backgroundStyle = {
    backgroundColor,
    zIndex: 999999,
  };

  return {
    isDarkMode,
    backgroundColor,
    fontColor,
    backgroundStyle,
    iconButtonUnderlayColor,
  };
};

export default useColorScheme;
