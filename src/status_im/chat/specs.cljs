(ns status-im.chat.specs
  (:require [cljs.spec.alpha :as s]))

(s/def :chat/chats (s/nilable map?))                              ; {id (string) chat (map)} active chats on chat's tab
(s/def :chat/current-chat-id (s/nilable string?))                 ; current or last opened chat-id
(s/def :chat/chat-id (s/nilable string?))                         ; what is the difference ? ^
(s/def :chat/new-chat-name (s/nilable string?))                   ; we have name in the new-chat why do we need this field
(s/def :chat/animations (s/nilable map?))                         ; {id (string) props (map)}
(s/def :chat/chat-ui-props (s/nilable map?))                      ; {id (string) props (map)}
(s/def :chat/chat-list-ui-props (s/nilable map?))
(s/def :chat/layout-height (s/nilable number?))                   ; height of chat's view layout
(s/def :chat/selected-participants (s/nilable set?))
(s/def :chat/public-group-topic (s/nilable string?))
(s/def :chat/public-group-topic-error (s/nilable string?))
(s/def :chat/messages (s/nilable map?))                           ; messages indexed by message-id
(s/def :chat/last-clock-value (s/nilable number?))                ; last logical clock value of messages in chat
(s/def :chat/loaded-chats (s/nilable seq?))
(s/def :chat/bot-db (s/nilable map?))
(s/def :chat/cooldowns (s/nilable number?))                       ; number of cooldowns given for spamming send button
(s/def :chat/inputs (s/nilable map?))
(s/def :chat/cooldown-enabled? (s/nilable boolean?))
(s/def :chat/last-outgoing-message-sent-at (s/nilable number?))
(s/def :chat/spam-messages-frequency (s/nilable number?))         ; number of consecutive spam messages sent
(s/def :chats/loading? (s/nilable boolean?))
