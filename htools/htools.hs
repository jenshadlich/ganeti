{-| Main htools binary.

-}

{-

Copyright (C) 2011, 2012 Google Inc.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301, USA.

-}

module Main (main) where

import Data.Char (toLower)
import System.Environment
import System.Exit
import System.IO

import Ganeti.HTools.Utils
import Ganeti.HTools.CLI (OptType, Options, parseOpts)
import qualified Ganeti.HTools.Program.Hail as Hail
import qualified Ganeti.HTools.Program.Hbal as Hbal
import qualified Ganeti.HTools.Program.Hscan as Hscan
import qualified Ganeti.HTools.Program.Hspace as Hspace

-- | Supported binaries.
personalities :: [(String, (Options -> [String] -> IO (), [OptType]))]
personalities = [ ("hail",   (Hail.main,   Hail.options))
                , ("hbal",   (Hbal.main,   Hbal.options))
                , ("hscan",  (Hscan.main,  Hscan.options))
                , ("hspace", (Hspace.main, Hspace.options))
                ]

-- | Display usage and exit.
usage :: String -> IO ()
usage name = do
  hPutStrLn stderr $ "Unrecognised personality '" ++ name ++ "'."
  hPutStrLn stderr "This program must be installed under one of the following\
                   \ names:"
  mapM_ (hPutStrLn stderr . ("  - " ++) . fst) personalities
  hPutStrLn stderr "Please either rename/symlink the program or set\n\
                   \the environment variable HTOOLS to the desired role."
  exitWith $ ExitFailure 1

main :: IO ()
main = do
  binary <- getEnv "HTOOLS" `catch` const getProgName
  let name = map toLower binary
      boolnames = map (\(x, y) -> (x == name, Just y)) personalities
  case select Nothing boolnames of
    Nothing -> usage name
    Just (fn, options) -> do
         cmd_args <- getArgs
         (opts, args) <- parseOpts cmd_args name options
         fn opts args
