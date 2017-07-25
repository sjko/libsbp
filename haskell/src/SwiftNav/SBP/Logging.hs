{-# OPTIONS_GHC -fno-warn-unused-imports #-}
{-# LANGUAGE NoImplicitPrelude           #-}
{-# LANGUAGE TemplateHaskell             #-}
{-# LANGUAGE RecordWildCards             #-}

-- |
-- Module:      SwiftNav.SBP.Logging
-- Copyright:   Copyright (C) 2015 Swift Navigation, Inc.
-- License:     LGPL-3
-- Maintainer:  Mark Fine <dev@swiftnav.com>
-- Stability:   experimental
-- Portability: portable
--
-- Logging and debugging messages from the device.

module SwiftNav.SBP.Logging
  ( module SwiftNav.SBP.Logging
  ) where

import BasicPrelude
import Control.Lens
import Control.Monad.Loops
import Data.Binary
import Data.Binary.Get
import Data.Binary.IEEE754
import Data.Binary.Put
import Data.ByteString
import Data.ByteString.Lazy    hiding (ByteString)
import Data.Int
import Data.Word
import SwiftNav.Encoding       ()
import SwiftNav.SBP.TH
import SwiftNav.SBP.Types

msgLog :: Word16
msgLog = 0x0401

-- | SBP class for message MSG_LOG (0x0401).
--
-- This message contains a human-readable payload string from the device
-- containing errors, warnings and informational messages at ERROR, WARNING,
-- DEBUG, INFO logging levels.
data MsgLog = MsgLog
  { _msgLog_level :: !Word8
    -- ^ Logging level
  , _msgLog_text :: !Text
    -- ^ Human-readable string
  } deriving ( Show, Read, Eq )

instance Binary MsgLog where
  get = do
    _msgLog_level <- getWord8
    _msgLog_text <- decodeUtf8 . toStrict <$> getRemainingLazyByteString
    return MsgLog {..}

  put MsgLog {..} = do
    putWord8 _msgLog_level
    putByteString $ encodeUtf8 _msgLog_text

$(makeSBP 'msgLog ''MsgLog)
$(makeJSON "_msgLog_" ''MsgLog)
$(makeLenses ''MsgLog)

msgFwd :: Word16
msgFwd = 0x0402

-- | SBP class for message MSG_FWD (0x0402).
--
-- This message provides the ability to forward messages over SBP.  This may
-- take the form of wrapping up SBP messages received by Piksi for logging
-- purposes or wrapping  another protocol with SBP.  The source identifier
-- indicates from what interface a forwarded stream derived. The protocol
-- identifier identifies what the expected protocol the forwarded msg contains.
-- Protocol 0 represents SBP and the remaining values are implementation
-- defined.
data MsgFwd = MsgFwd
  { _msgFwd_source    :: !Word8
    -- ^ source identifier
  , _msgFwd_protocol  :: !Word8
    -- ^ protocol identifier
  , _msgFwd_fwd_payload :: !Text
    -- ^ variable length wrapped binary message
  } deriving ( Show, Read, Eq )

instance Binary MsgFwd where
  get = do
    _msgFwd_source <- getWord8
    _msgFwd_protocol <- getWord8
    _msgFwd_fwd_payload <- decodeUtf8 . toStrict <$> getRemainingLazyByteString
    return MsgFwd {..}

  put MsgFwd {..} = do
    putWord8 _msgFwd_source
    putWord8 _msgFwd_protocol
    putByteString $ encodeUtf8 _msgFwd_fwd_payload

$(makeSBP 'msgFwd ''MsgFwd)
$(makeJSON "_msgFwd_" ''MsgFwd)
$(makeLenses ''MsgFwd)

msgTweet :: Word16
msgTweet = 0x0012

-- | SBP class for message MSG_TWEET (0x0012).
--
-- All the news fit to tweet.
data MsgTweet = MsgTweet
  { _msgTweet_tweet :: !Text
    -- ^ Human-readable string
  } deriving ( Show, Read, Eq )

instance Binary MsgTweet where
  get = do
    _msgTweet_tweet <- decodeUtf8 <$> getByteString 140
    return MsgTweet {..}

  put MsgTweet {..} = do
    putByteString $ encodeUtf8 _msgTweet_tweet

$(makeSBP 'msgTweet ''MsgTweet)
$(makeJSON "_msgTweet_" ''MsgTweet)
$(makeLenses ''MsgTweet)

msgPrintDep :: Word16
msgPrintDep = 0x0010

-- | SBP class for message MSG_PRINT_DEP (0x0010).
--
-- Deprecated.
data MsgPrintDep = MsgPrintDep
  { _msgPrintDep_text :: !Text
    -- ^ Human-readable string
  } deriving ( Show, Read, Eq )

instance Binary MsgPrintDep where
  get = do
    _msgPrintDep_text <- decodeUtf8 . toStrict <$> getRemainingLazyByteString
    return MsgPrintDep {..}

  put MsgPrintDep {..} = do
    putByteString $ encodeUtf8 _msgPrintDep_text

$(makeSBP 'msgPrintDep ''MsgPrintDep)
$(makeJSON "_msgPrintDep_" ''MsgPrintDep)
$(makeLenses ''MsgPrintDep)
