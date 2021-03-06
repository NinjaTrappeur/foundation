{-# LANGUAGE OverloadedStrings #-}
module CaseMapping (
  main
) where

import qualified Basement.String as BS (charMap)
import           Data.Char (toUpper, toLower)
import           Foundation
import           Foundation.IO 
import qualified Foundation.String as S

import CaseFolding
import SpecialCasing

main = do
  psc <- parseSC "SpecialCasing.txt"
  pcf <- parseCF "CaseFolding.txt"
  scs <- case psc of
           Left err -> putStrLn (show err) >> undefined
           Right sc -> return sc
  cfs <- case pcf of
           Left err -> putStrLn (show err) >> undefined
           Right cf -> return cf
  h <- openFile ("../../basement/Basement/String/CaseMapping.hs") WriteMode
  let comments = ("--" <>) <$>
                 take 2 (cfComments cfs) <> take 2 (scComments scs)
  (hPut h) . S.toBytes S.UTF8  . intercalate "\n" $
                      ["{-# LANGUAGE Rank2Types #-}"
                      ,"-- AUTOMATICALLY GENERATED - DO NOT EDIT"
                      ,"-- Generated by scripts/caseMapping/generateCaseMapping.sh"] 
                      <> comments <>
                      [""
                      ,"module Basement.String.CaseMapping where"
                      ,""
                      ,"import Data.Char"
                      ,"import Basement.UTF8.Types"
                      ,"",""]
  (hPut h) . S.toBytes S.UTF8 . intercalate "\n" $ (mapSC "upper" upper) (BS.charMap toUpper) scs
  (hPut h) . S.toBytes S.UTF8 . intercalate "\n" $ (mapSC "lower" lower) (BS.charMap toLower) scs
  (hPut h) . S.toBytes S.UTF8 . intercalate "\n" $ (mapSC "title" title) (BS.charMap toUpper) scs
  (hPut h) . S.toBytes S.UTF8 . intercalate "\n" $ mapCF (BS.charMap toLower) cfs
  closeFile h
