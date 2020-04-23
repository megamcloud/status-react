(ns status-im.core
  (:require [re-frame.core :as re-frame]
            [status-im.utils.error-handler :as error-handler]
            #_[status-im.utils.platform :as platform]
            [status-im.ui.components.react :as react]
            [reagent.core :as reagent]
            ["react-native-screens" :refer (enableScreens)]
            [status-im.utils.logging.core :as utils.logs]
            #_cljs.core.specs.alpha
            ["react-native" :as rn]))

(if js/goog.DEBUG
  (.ignoreWarnings (.-YellowBox ^js rn)
                   #js ["re-frame: overwriting"
                        "Warning: componentWillMount has been renamed, and is not recommended for use. See https://fb.me/react-async-component-lifecycle-hooks for details."
                        "Warning: componentWillUpdate has been renamed, and is not recommended for use. See https://fb.me/react-async-component-lifecycle-hooks for details."])
  (aset js/console "disableYellowBox" true))

(def app-registry (.-AppRegistry rn))
(def splash-screen (-> rn .-NativeModules .-SplashScreen))

(defn app-root []
  [react/view {}
   [react/text "hello"]])

(defn init []
  (utils.logs/init-logs)
  (error-handler/register-exception-handler!)
  #_(re-frame/dispatch-sync [:init/app-started])
  (enableScreens)
  (.registerComponent app-registry "StatusIm" #(reagent/reactify-component app-root))
  (.hide ^js splash-screen))
