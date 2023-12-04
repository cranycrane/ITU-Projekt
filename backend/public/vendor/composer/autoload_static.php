<?php

// autoload_static.php @generated by Composer

namespace Composer\Autoload;

class ComposerStaticInit38a10cb1e165d25ae033cc17f11642cd
{
    public static $prefixLengthsPsr4 = array (
        'A' => 
        array (
            'App\\' => 4,
        ),
    );

    public static $prefixDirsPsr4 = array (
        'App\\' => 
        array (
            0 => __DIR__ . '/../..' . '/',
        ),
    );

    public static $classMap = array (
        'Composer\\InstalledVersions' => __DIR__ . '/..' . '/composer/InstalledVersions.php',
    );

    public static function getInitializer(ClassLoader $loader)
    {
        return \Closure::bind(function () use ($loader) {
            $loader->prefixLengthsPsr4 = ComposerStaticInit38a10cb1e165d25ae033cc17f11642cd::$prefixLengthsPsr4;
            $loader->prefixDirsPsr4 = ComposerStaticInit38a10cb1e165d25ae033cc17f11642cd::$prefixDirsPsr4;
            $loader->classMap = ComposerStaticInit38a10cb1e165d25ae033cc17f11642cd::$classMap;

        }, null, ClassLoader::class);
    }
}
