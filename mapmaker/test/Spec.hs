import MapDSL.DSLParser
import MapDSL.DSLAst
import MapDSL.DSLAstHelper
import MapDSL.DSLValidate
import Test.Hspec
import System.IO
import Data.Text.Format
import Control.Exception
import Control.Monad
{- TODO : Add Test Cases for World-Map -}
readMapText :: String -> IO String
readMapText mapName = 
    let mapFileName = "resources/" ++ mapName ++ ".map"
    in do
        handle <- openFile mapFileName ReadMode
        hSetEncoding handle utf8_bom
        hGetContents handle


testMapGroundTruth1 = ([A,B,C,D],
                        (0, [0, 0, 0, 0], 0),
                        [[[[A,START], [B], [C], [D]],
                        [[EMPTY], [A]],
                        [[EMPTY], [A,GOAL]]]]
                        )

testMapGroundTruth2 = ([A,B,C,D],
                        (0, [0, 0, 0, 0], 0),
                        [[[[A,START], [B], [C], [D]],
                        [[EMPTY], [A]],
                        [[EMPTY], [A]],
                        [[EMPTY], [G,GOAL]]]]
                        )

testMapGroundTruth3 = ([A,B,C,D],
                        (0, [0, 0, 0, 0], 0),
                        [[[[A,START], [B], [C], [D]],
                        [[EMPTY], [A]],
                        [[EMPTY], [A]],
                        [[EMPTY], [G,GOAL]]],
                        [[[A], [B], [C], [D]],
                        [[EMPTY], [A]],
                        [[EMPTY], [A]],
                        [[EMPTY], [G]]]]
                        )

testMapGroundTruth4 = testMapGroundTruth2

testmap_itemsGt = ([A,C,A],
                    (1, [2, 3, 4, 5], 6),
                    [[[[A], [B,GOAL], [C], [D]],
                    [[A,START], [C], [C], [D]]]])

notitleMsg = invalidMapHeader ++ (titleErrorMsg 0)
nogoalcountMsg = invalidMapHeader ++ (goalCountErrorMsg 0)
nopatternMsg = invalidMapHeader ++ (patternCountErrorMsg 0)
badpatternMsg = invalidMapHeader ++ badPatternErrorMsg
noblockMsg = invalidMapHeader ++ (blockCountErrorMsg 0)
toomanyblockMsg = invalidMapHeader ++ (blockCountErrorMsg 2)
emptyblockMsg = invalidMapHeader ++ blockSizeErrorMsg
nogoalMsg = invalidMapHeader ++ (goalErrorMsg 0)
twogoalMsg = invalidMapHeader ++ (goalErrorMsg 2)
nostartMsg = invalidMapHeader ++ (startCountErrorMsg 0)
twostartMsg = invalidMapHeader ++ (startCountErrorMsg 2)
item_invalidglassMsg = invalidMapHeader ++ (glassCountErrorMsg 3)
item_invalidcountMsg = invalidMapHeader ++ (itemCountErrorMsg 2)

runTestOnMap mapFileName expectedValidationResult = 
    it (mapFileName ++ " matches groundtruth") $ do
        txt <- readMapText mapFileName

        let parseResult = parseMapText txt

        case parseResult of
            Right expr ->
                let blocks = blocksOf expr
                in let pattern = patternOf expr
                in let items = itemsOf expr
                in let Right (patternGt, itemsGt, mapGt) = expectedValidationResult
                in (pattern, items, blocks) `shouldBe` (patternGt, itemsGt, mapGt)
            Left msg ->
                let Left msgGts = expectedValidationResult
                in msg `shouldBe` msgGts

main :: IO ()
main = hspec $ do
    describe "parseMapText" $ do
        runTestOnMap "testmap1" $ Right testMapGroundTruth1
        runTestOnMap "testmap2" $ Right testMapGroundTruth2
        runTestOnMap "testmap4" $ Right testMapGroundTruth4
        runTestOnMap "testmap-items" $ Right testmap_itemsGt

    describe "validate parseMapText" $ do
        runTestOnMap "invalid-notitle" $ Left notitleMsg
        runTestOnMap "invalid-nogoalcount" $ Left nogoalcountMsg
        runTestOnMap "invalid-nopattern" $ Left nopatternMsg
        runTestOnMap "invalid-badpattern" $ Left badpatternMsg
        runTestOnMap "invalid-noblock" $ Left noblockMsg
        runTestOnMap "invalid-toomanyblock" $ Left toomanyblockMsg
        runTestOnMap "invalid-emptyblock" $ Left emptyblockMsg
        runTestOnMap "invalid-nogoal" $ Left nogoalMsg
        runTestOnMap "invalid-twogoal" $ Left twogoalMsg
        runTestOnMap "invalid-nostart" $ Left nostartMsg
        runTestOnMap "invalid-twostart" $ Left twostartMsg
        runTestOnMap "invalid-item-invalidglass" $ Left item_invalidglassMsg
        runTestOnMap "invalid-item-invalidcount" $ Left item_invalidcountMsg


            
