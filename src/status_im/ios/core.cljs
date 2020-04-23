(ns status-im.ios.core
  (:require [reagent.core :as reagent]
            [re-frame.core :refer [subscribe dispatch dispatch-sync]]
            status-im.utils.db
            status-im.ui.screens.db
            status-im.ui.screens.events
            status-im.subs
            ["react-native-languages" :default react-native-languages]
            ["react-native-shake" :as react-native-shake]
            ["react-native-screens" :refer (enableScreens)]
            [status-im.ui.screens.views :as views]
            [status-im.ui.components.react :as react]
            [status-im.core :as core]
            [status-im.utils.snoopy :as snoopy]
            [status-im.i18n :as i18n]))

(defn app-state-change-handler [state]
  (dispatch [:app-state-change state]))

(defn on-languages-change [^js event]
  (i18n/set-language (.-language event)))

(defn on-shake []
  (dispatch [:shake-event]))

(defn app-root [props]
  (let [keyboard-height (subscribe [:keyboard-height])]
    (reagent/create-class
     {:component-did-mount
      (fn [this]
        (.addListener ^js react/keyboard
                      "keyboardWillShow"
                      (fn [^js e]
                        (let [h (.. e -endCoordinates -height)]
                          (when-not (= h @keyboard-height)
                            (dispatch [:set :keyboard-height h])
                            (dispatch [:set :keyboard-max-height h])))))
        (.addListener ^js react/keyboard
                      "keyboardWillHide"
                      #(when-not (= 0 @keyboard-height)
                         (dispatch [:set :keyboard-height 0])))
        (.hide ^js react/splash-screen)
        (.addEventListener ^js react/app-state "change" app-state-change-handler)
        (.addEventListener react-native-languages "change" on-languages-change)
        (.addEventListener react-native-shake
                             "ShakeEvent"
                             on-shake)
        (dispatch [:set-initial-props (reagent/props this)]))
      :component-will-unmount
      (fn []
        (.removeEventListener ^js react/app-state "change" app-state-change-handler)
        (.removeEventListener react-native-languages "change" on-languages-change))
      :display-name "root"
      :reagent-render views/main})))

(defn init []
  (enableScreens)
  (core/init app-root)
  (snoopy/subscribe!))
