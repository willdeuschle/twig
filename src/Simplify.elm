module Simplify exposing (simplify, genGoodSentenceIds, genSentenceList)

import List exposing (head)
import String exposing (split, indices, trim, slice)
import Maybe exposing (..)
import Dict exposing (..)
import Array


-- BEGIN GENERATING THE SCORE DICTIONARY OF WORDS --
-- remove all the specified punctuation from our words


removePunc : List Char -> List String -> List String
removePunc chars strs =
    List.map (String.filter (\c -> not (List.member c chars))) strs



-- generate the list of words without any punctuation


createList : String -> List String
createList str =
    removePunc [ '.', ',', ':' ] (split " " (str))



-- take a list and collate it into a counted dictionary


constructDict : List String -> Dict String Int
constructDict lst =
    List.foldl (\str -> addItem str) Dict.empty lst



-- add an individual item to the dict


addItem : String -> Dict String Int -> Dict String Int
addItem str dict =
    case Dict.get str dict of
        Just v ->
            Dict.insert (String.toLower str) (v + 1) dict

        Nothing ->
            Dict.insert (String.toLower str) 1 dict



-- create the dictionary with the count of the words


genWordDictionary : String -> Dict String Int
genWordDictionary str =
    constructDict (createList str)



-- END OF THE DICT GENERATION --
-- BEGIN CONVERSION FROM THAT SCORE DICT TO A LIST OF IMPORTANT WORDS --
-- convert dictionary to list of tuples, sort it, then reverse so it is a high to low score ordering


dictToOrderedList : Dict String Int -> List ( String, Int )
dictToOrderedList dict =
    List.reverse (List.sortBy (\( str, int ) -> int) (Dict.toList dict))



-- remove small words so we don't track 'it's, 'I's, etc


removeSmallWords : List ( String, Int ) -> List ( String, Int )
removeSmallWords lst =
    List.filter (\( str, hits ) -> (String.length str) > 4) lst



-- decide how many of the important words we care about, collapse the dict to just a list of those word


selectImportantWords : List ( String, Int ) -> Int -> List String
selectImportantWords lst num =
    let
        abbrevLst =
            List.take num (removeSmallWords lst)
    in
        List.foldl (\( str, num ) -> ((::) str)) [] abbrevLst



-- combine all the work to generate the list of imporant words


genWordCountList : String -> List String
genWordCountList str =
    selectImportantWords (dictToOrderedList (genWordDictionary str)) 5



-- END CONVERSION FROM SCORE DICT TO IMPORTANT LIST OF WORDS --
-- BEGIN CONVERSION FROM TEXT TO LIST OF SENTENCES --
-- should think through this a little more later on, currently just splitting on periods


genSentenceList : String -> List String
genSentenceList str =
    restoreSentences (split ". " str)



-- adds punctuation back to the sentences


restoreSentences : List String -> List String
restoreSentences lst =
    case lst of
        [] ->
            []

        sent :: [] ->
            if sent == "" then
                []
            else
                [ (String.trim sent) ++ "." ]

        sent :: sents ->
            ((String.trim sent) ++ ".") :: (restoreSentences sents)



-- END CONVERSION FROM TEXT TO LIST OF SENTENCES --
-- BEGIN CONVERSION FROM WORD SCORE DICT AND SENTENCE LIST TO A FINALIZED SENTENCE LIST --
-- abstract functionality that calculates the score for titles and sentences


genHits : List String -> String -> Int
genHits word_list str =
    List.foldl
        (\word ->
            let
                numHits =
                    String.indices word (String.toLower str)
            in
                (+) (List.length numHits)
        )
        0
        word_list



-- calculate a score for each sentence based on our word score, sentence length, and title boost
-- this is the truly important function- everything else is just scaffolding arround this
-- given the article and the title, you can calculate the most imporant sentences
-- using whatever heuristics you deem fit


countSentenceScore : List String -> String -> String -> Float
countSentenceScore lst sent title =
    let
        raw_score =
            genHits lst sent

        title_boost =
            2 * (genHits (String.words title) sent)
    in
        (toFloat (raw_score + title_boost)) / toFloat (1 * List.length (String.words sent))



--create a dict that has a score for every sentence (keyed on the sentence)


annotateSentences : List String -> List String -> String -> Dict Int Float
annotateSentences sent_lst word_lst title =
    List.foldl (\( idx, sent ) -> Dict.insert idx (countSentenceScore word_lst sent title)) Dict.empty (Array.toIndexedList (Array.fromList sent_lst))



-- choose the top x best sentences from our dict of sentences with scores, provide a list of sentence ids, (reverse in there so we go high to low)


parseGoodSentenceIds : Dict Int Float -> Int -> List Int
parseGoodSentenceIds dict num =
    let
        organizedSents =
            List.reverse (List.sortBy (\( idx, hits ) -> hits) (Dict.toList dict))

        truncatedSents =
            List.take num organizedSents
    in
        List.foldl (\( idx, hits ) -> ((::) idx)) [] truncatedSents



-- takes list of sentence indices and the list of strings and creates the new text output


attachSentencesFromIds : List Int -> List String -> String
attachSentencesFromIds id_lst str_lst =
    let
        orderedIds =
            List.sortBy (\id -> id) id_lst

        arrayIds =
            Array.fromList orderedIds

        strArray =
            Array.fromList str_lst

        orderedSentArray =
            Array.map (\idx -> Maybe.withDefault "" (Array.get idx strArray)) arrayIds
    in
        String.join " " (Array.toList orderedSentArray)



-- factor this out so it can be used elsewhere


genGoodSentenceIds : String -> String -> List Int
genGoodSentenceIds str title =
    let
        sentLst =
            genSentenceList str
    in
        parseGoodSentenceIds (annotateSentences sentLst (genWordCountList str) title) 5



-- create the dict of sentence scores by generating our sentence list and our list of best words
-- calculate word scores, get sentence list, choose length of simplification, and construct the new text


genGoodSentenceList : String -> String -> String
genGoodSentenceList str title =
    let
        sentLst =
            genSentenceList str
    in
        attachSentencesFromIds (genGoodSentenceIds str title) sentLst



-- BEGIN CONVERSION FROM WORD SCORE DICT AND SENTENCE LIST TO A FINALIZED SENTENCE LIST --
-- EVENTUALLY USE THIS TO CALCULATE THE SIMPLIFICATION


simplify : String -> String -> String
simplify str title =
    genGoodSentenceList str title
