{-# OPTIONS -fno-implicit-prelude #-}
-----------------------------------------------------------------------------
-- 
-- Module      :  Data.Char
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/core/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  provisional
-- Portability :  portable
--
-- $Id: Char.hs,v 1.1 2001/06/28 14:15:02 simonmar Exp $
--
-- The Char type and associated operations.
--
-----------------------------------------------------------------------------

module Data.Char 
    (
      Char

    , isAscii, isLatin1, isControl
    , isPrint, isSpace,  isUpper
    , isLower, isAlpha,  isDigit
    , isOctDigit, isHexDigit, isAlphaNum  -- :: Char -> Bool

    , toUpper, toLower  -- :: Char -> Char

    , digitToInt        -- :: Char -> Int
    , intToDigit        -- :: Int  -> Char

    , ord               -- :: Char -> Int
    , chr               -- :: Int  -> Char
    , readLitChar       -- :: ReadS Char 
    , showLitChar       -- :: Char -> ShowS
    , lexLitChar	-- :: ReadS String

    , String

     -- Implementation checked wrt. Haskell 98 lib report, 1/99.
    ) where

#ifdef __GLASGOW_HASKELL__
import GHC.Base
import GHC.Show
import GHC.Read (readLitChar, lexLitChar, digitToInt)
#endif

#ifdef __HUGS__
isLatin1 c = True
#endif