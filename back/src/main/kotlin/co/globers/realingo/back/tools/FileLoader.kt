package co.globers.realingo.back.tools

import java.io.File
import java.net.URL

class FileLoader {

    companion object {
        fun getFileFromResource(fileName: String): File {
            val classLoader: ClassLoader = FileLoader::class.java.classLoader
            val resource: URL = classLoader.getResource(fileName)!!
            return File(resource.toURI())
        }
    }

}
