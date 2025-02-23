% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/blob_client_funcs.R, R/blob_copyurl.R
\name{list_blobs}
\alias{list_blobs}
\alias{upload_blob}
\alias{multiupload_blob}
\alias{download_blob}
\alias{multidownload_blob}
\alias{delete_blob}
\alias{create_blob_dir}
\alias{delete_blob_dir}
\alias{blob_exists}
\alias{blob_dir_exists}
\alias{copy_url_to_blob}
\alias{multicopy_url_to_blob}
\title{Operations on a blob container or blob}
\usage{
list_blobs(container, dir = "/", info = c("partial", "name", "all"),
  prefix = NULL, recursive = TRUE)

upload_blob(container, src, dest = basename(src), type = c("BlockBlob",
  "AppendBlob"), blocksize = if (type == "BlockBlob") 2^24 else 2^22,
  lease = NULL, put_md5 = FALSE, append = FALSE, use_azcopy = FALSE)

multiupload_blob(container, src, dest, recursive = FALSE,
  type = c("BlockBlob", "AppendBlob"), blocksize = if (type == "BlockBlob")
  2^24 else 2^22, lease = NULL, put_md5 = FALSE, append = FALSE,
  use_azcopy = FALSE, max_concurrent_transfers = 10)

download_blob(container, src, dest = basename(src), blocksize = 2^24,
  overwrite = FALSE, lease = NULL, check_md5 = FALSE,
  use_azcopy = FALSE)

multidownload_blob(container, src, dest, recursive = FALSE,
  blocksize = 2^24, overwrite = FALSE, lease = NULL, check_md5 = FALSE,
  use_azcopy = FALSE, max_concurrent_transfers = 10)

delete_blob(container, blob, confirm = TRUE)

create_blob_dir(container, dir)

delete_blob_dir(container, dir, recursive = FALSE, confirm = TRUE)

blob_exists(container, blob)

blob_dir_exists(container, dir)

copy_url_to_blob(container, src, dest, lease = NULL, async = FALSE,
  auth_header = NULL)

multicopy_url_to_blob(container, src, dest, lease = NULL, async = FALSE,
  max_concurrent_transfers = 10, auth_header = NULL)
}
\arguments{
\item{container}{A blob container object.}

\item{dir}{For \code{list_blobs}, a string naming the directory. Note that blob storage does not support real directories; this argument simply filters the result to return only blobs whose names start with the given value.}

\item{info}{For \code{list_blobs}, level of detail about each blob to return: a vector of names only; the name, size, blob type, and whether this blob represents a directory; or all information.}

\item{prefix}{For \code{list_blobs}, an alternative way to specify the directory.}

\item{recursive}{For the multiupload/download functions, whether to recursively transfer files in subdirectories. For \code{list_blobs}, whether to include the contents of any subdirectories in the listing. For \code{delete_blob_dir}, whether to recursively delete subdirectory contents as well.}

\item{src, dest}{The source and destination files for uploading and downloading. See 'Details' below.}

\item{type}{When uploading, the type of blob to create. Currently only block and append blobs are supported.}

\item{blocksize}{The number of bytes to upload/download per HTTP(S) request.}

\item{lease}{The lease for a blob, if present.}

\item{put_md5}{For uploading, whether to compute the MD5 hash of the blob(s). This will be stored as part of the blob's properties. Only used for block blobs.}

\item{append}{When uploading, whether to append the uploaded data to the destination blob. Only has an effect if \code{type="AppendBlob"}. If this is FALSE (the default) and the destination append blob exists, it is overwritten. If this is TRUE and the destination does not exist or is not an append blob, an error is thrown.}

\item{use_azcopy}{Whether to use the AzCopy utility from Microsoft to do the transfer, rather than doing it in R.}

\item{max_concurrent_transfers}{For \code{multiupload_blob} and \code{multidownload_blob}, the maximum number of concurrent file transfers. Each concurrent file transfer requires a separate R process, so limit this if you are low on memory.}

\item{overwrite}{When downloading, whether to overwrite an existing destination file.}

\item{check_md5}{For downloading, whether to verify the MD5 hash of the downloaded blob(s). This requires that the blob's \code{Content-MD5} property is set. If this is TRUE and the \code{Content-MD5} property is missing, a warning is generated.}

\item{blob}{A string naming a blob.}

\item{confirm}{Whether to ask for confirmation on deleting a blob.}

\item{async}{For \code{copy_url_to_blob} and \code{multicopy_url_to_blob}, whether the copy operation should be asynchronous (proceed in the background).}

\item{auth_header}{For \code{copy_url_to_blob} and \code{multicopy_url_to_blob}, an optional \code{Authorization} HTTP header to send to the source. This allows copying files that are not publicly available or otherwise have access restrictions.}
}
\value{
For \code{list_blobs}, details on the blobs in the container. For \code{download_blob}, if \code{dest=NULL}, the contents of the downloaded blob as a raw vector. For \code{blob_exists} a flag whether the blob exists.
}
\description{
Upload, download, or delete a blob; list blobs in a container; create or delete directories; check blob availability.
}
\details{
\code{upload_blob} and \code{download_blob} are the workhorse file transfer functions for blobs. They each take as inputs a \emph{single} filename as the source for uploading/downloading, and a single filename as the destination. Alternatively, for uploading, \code{src} can be a \link{textConnection} or \link{rawConnection} object; and for downloading, \code{dest} can be NULL or a \code{rawConnection} object. If \code{dest} is NULL, the downloaded data is returned as a raw vector, and if a raw connection, it will be placed into the connection. See the examples below.

\code{multiupload_blob} and \code{multidownload_blob} are functions for uploading and downloading \emph{multiple} files at once. They parallelise file transfers by using the background process pool provided by AzureRMR, which can lead to significant efficiency gains when transferring many small files. There are two ways to specify the source and destination for these functions:
\itemize{
\item Both \code{src} and \code{dest} can be vectors naming the individual source and destination pathnames.
\item The \code{src} argument can be a wildcard pattern expanding to one or more files, with \code{dest} naming a destination directory. In this case, if \code{recursive} is true, the file transfer will replicate the source directory structure at the destination.
}

\code{upload_blob} and \code{download_blob} can display a progress bar to track the file transfer. You can control whether to display this with \code{options(azure_storage_progress_bar=TRUE|FALSE)}; the default is TRUE.

\code{multiupload_blob} can upload files either as all block blobs or all append blobs, but not a mix of both.

\code{blob_exists} and \code{blob_dir_exists} test for the existence of a blob and directory, respectively.

\code{copy_url_to_blob} transfers the contents of the file at the specified HTTP[S] URL directly to blob storage, without requiring a temporary local copy to be made. \code{multicopy_url_to_blob} does the same, for multiple URLs at once. These functions have a current file size limit of 256MB.
}
\section{AzCopy}{

\code{upload_blob} and \code{download_blob} have the ability to use the AzCopy commandline utility to transfer files, instead of native R code. This can be useful if you want to take advantage of AzCopy's logging and recovery features; it may also be faster in the case of transferring a very large number of small files. To enable this, set the \code{use_azcopy} argument to TRUE.

The following points should be noted about AzCopy:
\itemize{
\item It only supports SAS and AAD (OAuth) token as authentication methods. AzCopy also expects a single filename or wildcard spec as its source/destination argument, not a vector of filenames or a connection.
\item Currently, it does \emph{not} support appending data to existing blobs.
}
}

\section{Directories}{

Blob storage does not have true directories, instead using filenames containing a separator character (typically '/') to mimic a directory structure. This has some consequences:
\itemize{
\item The \code{isdir} column in the data frame output of \code{list_blobs} is a best guess as to whether an object represents a file or directory, and may not always be correct. Currently, \code{list_blobs} assumes that any object with a file size of zero is a directory.
\item Zero-length files can cause problems for the blob storage service as a whole (not just AzureStor). Try to avoid uploading such files.
\item \code{create_blob_dir} and \code{delete_blob_dir} are guaranteed to function as expected only for accounts with hierarchical namespaces enabled. When this feature is disabled, directories do not exist as objects in their own right: to create a directory, simply upload a blob to that directory. To delete a directory, delete all the blobs within it; as far as the blob storage service is concerned, the directory then no longer exists.
\item Similarly, the output of \code{list_blobs(recursive=TRUE)} can vary based on whether the storage account has hierarchical namespaces enabled.
\item \code{blob_exists} will return FALSE for a directory when the storage account does not have hierarchical namespaces enabled.
}
}

\examples{
\dontrun{

cont <- blob_container("https://mystorage.blob.core.windows.net/mycontainer", key="access_key")

list_blobs(cont)

upload_blob(cont, "~/bigfile.zip", dest="bigfile.zip")
download_blob(cont, "bigfile.zip", dest="~/bigfile_downloaded.zip")

delete_blob(cont, "bigfile.zip")

# uploading/downloading multiple files at once
multiupload_blob(cont, "/data/logfiles/*.zip", "/uploaded_data")
multiupload_blob(cont, "myproj/*")  # no dest directory uploads to root
multidownload_blob(cont, "jan*.*", "/data/january")

# append blob: concatenating multiple files into one
upload_blob(cont, "logfile1", "logfile", type="AppendBlob", append=FALSE)
upload_blob(cont, "logfile2", "logfile", type="AppendBlob", append=TRUE)
upload_blob(cont, "logfile3", "logfile", type="AppendBlob", append=TRUE)

# you can also pass a vector of file/pathnames as the source and destination
src <- c("file1.csv", "file2.csv", "file3.csv")
dest <- paste0("uploaded_", src)
multiupload_blob(cont, src, dest)

# uploading serialized R objects via connections
json <- jsonlite::toJSON(iris, pretty=TRUE, auto_unbox=TRUE)
con <- textConnection(json)
upload_blob(cont, con, "iris.json")

rds <- serialize(iris, NULL)
con <- rawConnection(rds)
upload_blob(cont, con, "iris.rds")

# downloading files into memory: as a raw vector, and via a connection
rawvec <- download_blob(cont, "iris.json", NULL)
rawToChar(rawvec)

con <- rawConnection(raw(0), "r+")
download_blob(cont, "iris.rds", con)
unserialize(con)

# copy from a public URL: Iris data from UCI machine learning repository
copy_url_to_blob(cont,
    "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data",
    "iris.csv")

}
}
\seealso{
\link{blob_container}, \link{az_storage}, \link{storage_download}, \link{call_azcopy}

\href{https://github.com/Azure/azure-storage-azcopy}{AzCopy version 10 on GitHub}
\href{https://docs.microsoft.com/en-us/rest/api/storageservices/understanding-block-blobs--append-blobs--and-page-blobs}{Guide to the different blob types}
}
