{-# OPTIONS -fno-implicit-prelude #-}
-----------------------------------------------------------------------------
-- 
-- Module      :  Foreign.StablePtr
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/core/LICENSE)
-- 
-- Maintainer  :  ffi@haskell.org
-- Stability   :  provisional
-- Portability :  portable
--
-- $Id: StablePtr.hs,v 1.2 2001/07/03 11:37:50 simonmar Exp $
--
-- Stable pointers.
--
-----------------------------------------------------------------------------

module Foreign.StablePtr
        ( StablePtr,         -- abstract
        , newStablePtr       -- :: a -> IO (StablePtr a)
        , deRefStablePtr     -- :: StablePtr a -> IO a
        , freeStablePtr      -- :: StablePtr a -> IO ()
        , castStablePtrToPtr -- :: StablePtr a -> Ptr ()
        , castPtrToStablePtr -- :: Ptr () -> StablePtr a
        ) where

import Data.Dynamic

#ifdef __GLASGOW_HASKELL__
import GHC.Stable
import GHC.Err
#endif

#include "Dynamic.h"
INSTANCE_TYPEABLE1(StablePtr,stablePtrTc,"StablePtr")