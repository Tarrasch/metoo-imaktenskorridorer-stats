#!/usr/bin/env stack
-- stack --resolver lts-9.13 script --package regex-pcre
{-# LANGUAGE LambdaCase #-}
import Control.Monad
import Text.Regex.PCRE
import Data.Maybe
import Data.Char
import Data.Bits ((.|.))

-- Partier i godtycklig ordning
data Party = 
        S
      | V
      | M
      | C
      | L
      | SD
      | MP
      | KD
      | FI
      | Other
  deriving (Show, Eq, Enum, Bounded)

allParties :: [Party]
allParties = [minBound .. maxBound]

findParty :: String -> Maybe Party
findParty line = listToMaybe . catMaybes $ map ($line) $ 
        inParenthesis
        ++ unknowns
        ++ fullnames
        ++ youths
        ++ shortNames
        ++ textual

type Filters = [(String -> Maybe Party)]

fullnames :: Filters
fullnames = [ const Nothing
        , "centerpartiet" ~> C
        , "miljöpartie" ~> C
        , "Feministiskt? initiativ" ~> FI
        , "Moderat" ~> M
        , "Liberalerna" ~> L
        , "Socialdemokr" ~> S
        , "Sverigedemokr" ~> SD
        , "Kristdemokr" ~> KD
        , "Center" ~> C
        ]

youths :: Filters
youths = [ const Nothing
        , "Unga Feminister" ~> FI
        , "Ung Vänster" ~> FI
        , "SSU" ~> S
        , "KDU" ~> KD
        , "Grön Ungdom" ~> MP
        , "Liberala ungdomsförbundet" ~> L
        , "CUF" ~> C
        , word "Muf" ~> M
        , "Liberala studenter" ~> L
        , word "Centerstudenter" ~> C
        , "LUF" ~> L
        , "SDU" ~> SD
        ]

shortNames :: Filters
shortNames = [ const Nothing
        , word "MP" ~> MP
        , word "SD" ~> SD
        , word "KD" ~> KD
        , word "FI" ~> FI
        , word "S" ~> S
        , word "C" ~> C
        , word "L" ~> L
        , word "M" ~> M
        , word "V" ~> V
        , word "F!" ~> FI
        , word "©" ~> C -- antar jag??
        ]

textual :: Filters
textual = [ const Nothing
        , "M\\+Muf" ~> M
        , "\\(M$" ~> M
        ]

unknowns :: Filters
unknowns = map (~> Other) $ [ "goddamntrailingcommas"
        , "ordförande fler unga"
        , "SVEA"
        , "jagvillhabostad.nu"
        , "regionråd"
        , "Byggnads"
        , "jämställdhetsminister"
        , "Sveriges Elevkårer"
        , "Regionfullmäktige"
        , "European Youth Parliament"
        , "lokalt parti"
        , "politisk sekreterare,"
        , "Maktsalongen"
        , "Sveriges Ungdomsråd."
        , "Nordenchef Ashoka"
        , "Vi Unga"
        ]

inParenthesis :: Filters
inParenthesis = [parenRegex p ~> p | p <- allParties]

parenRegex p = "\\(" ++ show p ++ "\\)"

compilationOptions = defaultCompOpt .|. compCaseless
myMakeRegex = makeRegexOpts compilationOptions defaultExecOpt
        
line =~- regex = matchTest (myMakeRegex regex) (line :: String)

word regex = "[\\W\\s\\b]" ++ regex ++ "([\\W\\s\\b]|$)"

(~>) :: String -> Party -> (String -> Maybe Party)
(~>) regex party line | line =~- regex = Just party
(~>) regex party line | otherwise            = Nothing 

assert True  = return ()
assert False = putStrLn "Assert failed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

main = do
    assert $ findParty "Ebba Busch Thor, partiledare (KD)" == Just KD
    assert $ findParty "Annie Lööf, partiledare (C)" == Just C
    assert $ findParty "Maria Kjellberg, kommunalråd (MP)" == Just MP
    printKnownParties


printKnownParties = do
   lines <- fmap lines getContents
   let parties = catMaybes $ map findParty lines
   mapM_ print (filter (/=Other) parties)


printUnknownsMain = do
   lines <- fmap lines getContents
   forM (lines `zip` map findParty lines) $
        \case
          (line, Nothing) -> putStrLn line
          _               -> return ()

