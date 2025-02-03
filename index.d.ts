/**
 * Represents information about a music track.
 */
export interface TrackInfo {
    /**
     * The title of the track.
     */
    title: string;

    /**
     * The artist of the track.
     */
    artist: string;

    /**
     * The album name of the track (optional).
     */
    album?: string;

    /**
     * The URL or path to the artwork image for the track (optional).
     */
    artwork?: string;
}

/**
 * Properties for configuring the music player.
 */
export interface PlayerProps {
    /**
     * The URL of the audio source to be played (optional).
     */
    sourceUrl?: string;

    /**
     * The audio file to be played (optional).
     */
    file?: File;

    /**
     * Whether the player should start playing automatically (optional).
     */
    autoPlay?: boolean;

    /**
     * The interval in seconds at which the player should seek (optional).
     */
    seekInterval?: number;

    /**
     * Callback function to be called when the audio ends (optional).
     */
    onEnd?: () => void;

    /**
     * Callback function to be called periodically with the current progress (optional).
     * @param progress - The current progress of the audio playback as a percentage.
     */
    onProgress?: (progress: number) => void;

    /**
     * Information about the track being played (optional).
     */
    trackInfo?: TrackInfo;
}

/**
 * The result returned by the usePlayer hook.
 */
export interface UsePlayerResult {
    /**
     * Whether the player is currently loading the audio.
     */
    isLoading: boolean;

    /**
     * Whether the audio is currently playing.
     */
    isPlaying: boolean;

    /**
     * The total duration of the audio in seconds.
     */
    totalDuration: number;

    /**
     * Function to get the duration of the audio.
     * @returns A promise that resolves when the duration is retrieved.
     */
    getDuration: () => Promise<void>;

    /**
     * Function to start playing the audio.
     * @returns A promise that resolves when the audio starts playing.
     */
    playSound: () => Promise<void>;

    /**
     * Function to pause the audio playback.
     */
    pauseSound: () => void;

    /**
     * Function to stop the audio playback.
     */
    stopSound: () => void;
}

/**
 * Custom hook to manage audio playback.
 * @param props - The properties to configure the player.
 * @returns The result of the player state and control functions.
 */
declare function usePlayer(props: PlayerProps): UsePlayerResult;

export default usePlayer;
