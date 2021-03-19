package co.globers.realingo.back.tools

import java.io.InputStream

class FileLoader {

    companion object {
        fun getFileFromResource(fileName: String): String {
            val classLoader: ClassLoader = FileLoader::class.java.classLoader
            val resource: InputStream = classLoader.getResourceAsStream(fileName)!!
            return resource.reader().readText()
        }
    }

}
