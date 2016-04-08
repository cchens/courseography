{-# LANGUAGE FlexibleContexts, GADTs, MultiParamTypeClasses,
    OverloadedStrings, TypeFamilies #-}

{-|
Description: Functions that insert/update course information in the database.

This module contains a bunch of functions related to inserting information
into the database. These functions are used as helpers for the WebParsing module.
-}

module Database.CourseInsertion
    (insertCourse,
     setTutorialEnrolment,
     setPracticalEnrolment,
     saveGraphJSON,
     insertGraph) where

import qualified Data.Text as T
import qualified Data.ByteString.Lazy.Char8 as BSL
import Happstack.Server.SimpleHTTP
import Control.Monad.IO.Class (MonadIO)
import Control.Monad.Trans.Reader (ReaderT)
import Data.Maybe (fromMaybe)
import Config (databasePath)
import Database.Persist.Sqlite (selectFirst, fromSqlKey, insertMany_, insert_, insert, SqlBackend, (=.), (==.), updateWhere, runSqlite)
import Database.Tables
import Data.Aeson

-- | Insert SVG graph and return its id
insertGraph :: String -> ServerPartT IO Response
insertGraph nameStr = do
    response <- runSqlite databasePath $ do
        nameExists <- selectFirst [GraphTitle ==. nameStr] []
        case nameExists of
          Nothing -> runSqlite databasePath $ do
                         gId <- insert $ Graph nameStr 256 256
                         return $ Just $ show $ fromSqlKey gId
          Just _ -> return Nothing
    case response of
        Nothing -> resp 420 $ toResponse nameStr
        Just gId -> ok $ toResponse gId

-- | Inserts SVG graph data into Texts, Shapes, and Paths tables
-- saveGraphJSON :: [Value] -> ()
saveGraphJSON :: String -> IO Response
saveGraphJSON jsonStr = do
    let jsonObj = decode $ BSL.pack jsonStr
    case jsonObj of
        Nothing -> return $ toResponse ("Error" :: String)
        Just (SvgJSON texts shapes paths) -> do
            response <- runSqlite databasePath $ do insertMany_ texts
                                                    insertMany_ shapes
                                                    insertMany_ paths
            return $ toResponse ("Success" :: String)

-- | Inserts course into the Courses table.
insertCourse :: MonadIO m => Course -> ReaderT SqlBackend m ()
insertCourse course =
    insert_ $ Courses (name course)
                      (title course)
                      (description course)
                      (manualTutorialEnrolment course)
                      (manualPracticalEnrolment course)
                      (prereqs course)
                      (exclusions course)
                      (breadth course)
                      (distribution course)
                      (prereqString course)
                      (coreqs course)
                      []

-- | Updates the manualTutorialEnrolment field of the given course.
setTutorialEnrolment :: MonadIO m => T.Text -> Bool -> ReaderT SqlBackend m ()
setTutorialEnrolment course val =
    updateWhere [CoursesCode ==. course]
                [CoursesManualTutorialEnrolment =. Just val]

-- | Updates the manualPracticalEnrolment field of the given course.
setPracticalEnrolment :: MonadIO m => T.Text -> Bool -> ReaderT SqlBackend m ()
setPracticalEnrolment course val =
    updateWhere [CoursesCode ==. course]
                [CoursesManualPracticalEnrolment =. Just val]

