{-# OPTIONS -fno-implicit-prelude #-}
-----------------------------------------------------------------------------
-- 
-- Module      :  Foreign.Marshal.Utils
-- Copyright   :  (c) The FFI task force 2001
-- License     :  BSD-style (see the file libraries/core/LICENSE)
-- 
-- Maintainer  :  ffi@haskell.org
-- Stability   :  provisional
-- Portability :  portable
--
-- $Id: Utils.hs,v 1.3 2002/02/05 17:32:25 simonmar Exp $
--
-- Utilities for primitive marshaling
--
-----------------------------------------------------------------------------

module Foreign.Marshal.Utils (

  -- combined allocation and marshalling
  --
  withObject,    -- :: Storable a => a -> (Ptr a -> IO b) -> IO b
  {- FIXME: should be `with' -}
  new,           -- :: Storable a => a -> IO (Ptr a)

  -- marshalling of Boolean values (non-zero corresponds to `True')
  --
  fromBool,      -- :: Num a => Bool -> a
  toBool,	 -- :: Num a => a -> Bool

  -- marshalling of Maybe values
  --
  maybeNew,      -- :: (      a -> IO (Ptr a))
		 -- -> (Maybe a -> IO (Ptr a))
  maybeWith,     -- :: (      a -> (Ptr b -> IO c) -> IO c)
		 -- -> (Maybe a -> (Ptr b -> IO c) -> IO c)
  maybePeek,     -- :: (Ptr a -> IO        b )
		 -- -> (Ptr a -> IO (Maybe b))

  -- marshalling lists of storable objects
  --
  withMany,      -- :: (a -> (b -> res) -> res) -> [a] -> ([b] -> res) -> res

  -- Haskellish interface to memcpy and memmove
  -- (argument order: destination, source)
  --
  copyBytes,     -- :: Ptr a -> Ptr a -> Int -> IO ()
  moveBytes      -- :: Ptr a -> Ptr a -> Int -> IO ()
) where

import Data.Maybe

#ifdef __GLASGOW_HASKELL__
import Foreign.Ptr	        ( Ptr, nullPtr )
import GHC.Storable		( Storable(poke) )
import Foreign.C.TypesISO    	( CSize )
import Foreign.Marshal.Alloc 	( malloc, alloca )
import GHC.IOBase
import GHC.Real			( fromIntegral )
import GHC.Num
import GHC.Base
#endif

-- combined allocation and marshalling
-- -----------------------------------

-- allocate storage for a value and marshal it into this storage
--
new     :: Storable a => a -> IO (Ptr a)
new val  = 
  do 
    ptr <- malloc
    poke ptr val
    return ptr

-- allocate temporary storage for a value and marshal it into this storage
--
-- * see the life time constraints imposed by `alloca'
--
{- FIXME: should be called `with' -}
withObject       :: Storable a => a -> (Ptr a -> IO b) -> IO b
withObject val f  =
  alloca $ \ptr -> do
    poke ptr val
    res <- f ptr
    return res


-- marshalling of Boolean values (non-zero corresponds to `True')
-- -----------------------------

-- convert a Haskell Boolean to its numeric representation
--
fromBool       :: Num a => Bool -> a
fromBool False  = 0
fromBool True   = 1

-- convert a Boolean in numeric representation to a Haskell value
--
toBool :: Num a => a -> Bool
toBool  = (/= 0)


-- marshalling of Maybe values
-- ---------------------------

-- allocate storage and marshall a storable value wrapped into a `Maybe'
--
-- * the `nullPtr' is used to represent `Nothing'
--
maybeNew :: (      a -> IO (Ptr a))
	 -> (Maybe a -> IO (Ptr a))
maybeNew  = maybe (return nullPtr)

-- converts a withXXX combinator into one marshalling a value wrapped into a
-- `Maybe'
--
maybeWith :: (      a -> (Ptr b -> IO c) -> IO c) 
	  -> (Maybe a -> (Ptr b -> IO c) -> IO c)
maybeWith  = maybe ($ nullPtr)

-- convert a peek combinator into a one returning `Nothing' if applied to a
-- `nullPtr' 
--
maybePeek                           :: (Ptr a -> IO b) -> Ptr a -> IO (Maybe b)
maybePeek peek ptr | ptr == nullPtr  = return Nothing
		   | otherwise       = do a <- peek ptr; return (Just a)


-- marshalling lists of storable objects
-- -------------------------------------

-- replicates a withXXX combinator over a list of objects, yielding a list of
-- marshalled objects
--
withMany :: (a -> (b -> res) -> res)  -- withXXX combinator for one object
	 -> [a]			      -- storable objects
	 -> ([b] -> res)	      -- action on list of marshalled obj.s
	 -> res
withMany _       []     f = f []
withMany withFoo (x:xs) f = withFoo x $ \x' ->
			      withMany withFoo xs (\xs' -> f (x':xs'))


-- Haskellish interface to memcpy and memmove
-- ------------------------------------------

-- copies the given number of bytes from the second area (source) into the
-- first (destination); the copied areas may *not* overlap
--
copyBytes               :: Ptr a -> Ptr a -> Int -> IO ()
copyBytes dest src size  = memcpy dest src (fromIntegral size)

-- copies the given number of elements from the second area (source) into the
-- first (destination); the copied areas *may* overlap
--
moveBytes               :: Ptr a -> Ptr a -> Int -> IO ()
moveBytes dest src size  = memmove dest src (fromIntegral size)


-- auxilliary routines
-- -------------------

-- basic C routines needed for memory copying
--
foreign import ccall unsafe memcpy  :: Ptr a -> Ptr a -> CSize -> IO ()
foreign import ccall unsafe memmove :: Ptr a -> Ptr a -> CSize -> IO ()