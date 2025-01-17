/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {SafeAreaView, ScrollView, StyleSheet, View} from 'react-native';
import useColorScheme from './hooks/useColorScheme';
import PlayerControls from './components/audio-player-controls/playerControls';
import AudioPlayerMedia from './components/audio-player-media';
import AudioPlayerContent from './components/audio-player-content';
import {Text} from 'react-native';
import {mockAudioContent, mockTrackInfo} from './data/mockData';
import usePlayer from './hooks/usePlayer';
import AudioPlayerDuration from './components/audio-player-duration';

function App(): React.JSX.Element {
  const {backgroundStyle} = useColorScheme();
  const {
    playSound,
    pauseSound,
    isPlaying,
    isLoading,
    totalDuration,
    progress,
    elapsedTime,
    onSeekForward,
    onSeekBackward,
  } = usePlayer({
    sourceUrl:
      'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3',
    autoPlay: false,
    trackInfo: mockTrackInfo,
  });

  const onPlay = () => {
    playSound();
  };

  const onPause = () => {
    pauseSound();
  };

  const MockContent = (
    <View style={styles.mockContent}>
      <Text style={styles.mockContentTitle}>{mockAudioContent.title}</Text>
      <Text style={styles.mockContentArtist}>{mockAudioContent.artist}</Text>
    </View>
  );

  return (
    <SafeAreaView style={backgroundStyle}>
      <ScrollView>
        <AudioPlayerMedia
          thumbnail={require('./assets/images/sample-image.jpg')}
        />
        <AudioPlayerContent content={MockContent} />
        <AudioPlayerDuration
          totalDuration={totalDuration}
          currentDuration={elapsedTime}
          progress={progress}
        />
        <PlayerControls
          isPlaying={isPlaying}
          onPlay={onPlay}
          onPause={onPause}
          isLoading={isLoading}
          onSeekForward={onSeekForward}
          onSeekBackward={onSeekBackward}
        />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  mockContent: {
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    textAlign: 'center',
  },
  mockContentTitle: {
    fontSize: 24,
    marginVertical: 5,
    fontWeight: 'bold',
  },
  mockContentArtist: {
    fontSize: 18,
    marginVertical: 5,
  },
});

export default App;
