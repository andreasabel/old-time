-----------------------------------------------------------------------------
-- 
-- Module      :  Control.Monad.Identity
-- Copyright   :  (c) Andy Gill 2001,
--		  (c) Oregon Graduate Institute of Science and Technology, 2001
-- License     :  BSD-style (see the file libraries/core/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  experimental
-- Portability :  portable
--
-- $Id: Identity.hs,v 1.1 2001/06/28 14:15:02 simonmar Exp $
--
-- The Identity monad.
--
--	  Inspired by the paper:
--	  \em{Functional Programming with Overloading and
--	      Higher-Order Polymorphism},
--	    \A[HREF="http://www.cse.ogi.edu/~mpj"]{Mark P Jones},
--		  Advanced School of Functional Programming, 1995.}
--
-----------------------------------------------------------------------------

module Control.Monad.Identity (
	Identity(..),
	runIdentity,
	module Control.Monad,
	module Control.Monad.Fix,
   ) where

import Prelude

import Control.Monad
import Control.Monad.Fix

-- ---------------------------------------------------------------------------
-- Identity wrapper
--
--	Abstraction for wrapping up a object.
--	If you have an monadic function, say:
--
--	    example :: Int -> IdentityMonad Int
--	    example x = return (x*x)
--
--      you can "run" it, using
--
--	  Main> runIdentity (example 42)
--	  1764 :: Int

newtype Identity a = Identity { runIdentity :: a }

-- ---------------------------------------------------------------------------
-- Identity instances for Functor and Monad

instance Functor Identity where
	fmap f m = Identity (f (runIdentity m))

instance Monad Identity where
	return a = Identity a
	m >>= k  = k (runIdentity m)

instance MonadFix Identity where
	mfix f = Identity (fix (runIdentity . f))