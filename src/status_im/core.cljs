(ns status-im.core
  (:require [re-frame.core :as re-frame]
            [status-im.utils.error-handler :as error-handler]
            #_[status-im.utils.platform :as platform]
            [status-im.ui.screens.views :as views]
            [status-im.ui.components.react :as react]
            [reagent.core :as reagent]
            #_status-im.utils.db
            #_status-im.ui.screens.db
            #_status-im.ui.screens.events
            status-im.subs
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

(defn app-state-change-handler [state]
  (re-frame/dispatch [:app-state-change state]))

(defn app-root [props]
  (let [keyboard-height (re-frame/subscribe [:keyboard-height])]
    (reagent/create-class
     {:component-did-mount
      (fn [this]
        #_(.addListener react/keyboard
                        "keyboardWillShow"
                        (fn [^js e]
                          (let [h (.. e -endCoordinates -height)]
                            (when-not (= h @keyboard-height)
                              (dispatch [:set :keyboard-height h])
                              (dispatch [:set :keyboard-max-height h])))))
        #_(.addListener react/keyboard
                        "keyboardWillHide"
                        #(when-not (= 0 @keyboard-height)
                           (dispatch [:set :keyboard-height 0])))
        (.addEventListener react/app-state "change" app-state-change-handler)
        #_(.addEventListener react-native-languages "change" on-languages-change)
        #_(.addEventListener react-native-shake
                             "ShakeEvent"
                             on-shake)
        (re-frame/dispatch [:set-initial-props (reagent/props this)]))
      :component-will-unmount
      (fn []
        #_(.removeEventListener react/app-state "change" app-state-change-handler)
        #_(.removeEventListener react-native-languages "change" on-languages-change))
      :display-name "root"
      :reagent-render views/main})))

(defn init []
  (utils.logs/init-logs)
  (error-handler/register-exception-handler!)

  (enableScreens)
  (.registerComponent app-registry "StatusIm" #(reagent/reactify-component app-root))
  #_(re-frame/dispatch-sync [:init/app-started])
  (.hide ^js splash-screen))
