/**
 * react-native-dynamic-bundle
 * @flow
 */
/**
 * Set ths assets path for copying assets while reload bundle due to
 * the resources cannot be loaded if it is not in the directory
 * as same as bundle.
 */
export declare const setAssetsPath: (path: string) => void;
/**
 * Set the active Javascript bundle to the bundle with the given bundle ID in
 * the registry. This will cause the given bundle to be loaded on the next app
 * startup or invocation of `reloadBundle()`.
 */
export declare const setActiveBundle: (bundleId: string) => void;
/**
 * Register a Javascript bundle in the bundle registry. The path to the bundle
 * should be relative to the documents directory on iOS and to the internal app
 * storage directory on Android, i.e. the directory returned by `getFilesDir()`.
 */
export declare const registerBundle: (bundleId: string, relativePath: string) => void;
/**
 * Unregister a bundle from the bundle registry.
 */
export declare const unregisterBundle: (bundleId: string) => void;
/**
 * Reload the bundle that is used by the app immediately. This can be used to
 * apply a new bundle that was set by `setActiveBundle()` immediately.
 */
export declare const reloadBundle: () => void;
/**
 * Returns a promise that resolves to an object with the contents of the bundle
 * registry, where the keys are the bundle identifiers and values are the
 * bundle locations encoded as a file URL.
 */
export declare const getBundles: () => Promise<{
    [key: string]: string;
}>;
/**
 * Returns a promise that resolves to the currently active bundle identifier.
 * if the default bundle (i.e. the bundle that was packaged into the native app)
 * is active this method will resolve to `null`.
 */
export declare const getActiveBundle: () => Promise<string>;
