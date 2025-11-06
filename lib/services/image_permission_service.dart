import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ImagePermissionService {
  static final ImagePermissionService _instance = ImagePermissionService._internal();
  factory ImagePermissionService() => _instance;
  ImagePermissionService._internal();

  /// Solicita permiso de cámara y abre la cámara si se concede
  Future<XFile?> pickImageFromCamera(BuildContext context) async {
    try {
      final PermissionStatus cameraStatus = await Permission.camera.request();
      
      if (cameraStatus.isGranted) {
        final ImagePicker picker = ImagePicker();
        return await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
      } else if (cameraStatus.isDenied) {
        _showPermissionDeniedDialog(
          context,
          'Permiso de cámara denegado',
          'Para tomar fotos, necesitamos acceso a tu cámara.',
          Permission.camera,
        );
        return null;
      } else if (cameraStatus.isPermanentlyDenied) {
        _showPermanentlyDeniedDialog(
          context,
          'Permiso de cámara',
          'Has denegado permanentemente el acceso a la cámara. Por favor, habilítalo en la configuración de la aplicación.',
        );
        return null;
      }
      
      return null;
    } catch (e) {
      _showErrorDialog(context, 'No se pudo acceder a la cámara: $e');
      return null;
    }
  }

  /// Solicita permiso de galería y abre la galería si se concede
  Future<XFile?> pickImageFromGallery(BuildContext context) async {
    try {
      PermissionStatus galleryStatus;
      
      // Detectar versión de Android correctamente
      if (await _isAndroid13OrHigher()) {
        // Android 13+ (API 33+): usar Permission.photos
        galleryStatus = await Permission.photos.request();
      } else {
        // Android 12 y anteriores: usar Permission.storage
        galleryStatus = await Permission.storage.request();
      }
      
      if (galleryStatus.isGranted || galleryStatus.isLimited) {
        final ImagePicker picker = ImagePicker();
        return await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
      } else if (galleryStatus.isDenied) {
        _showPermissionDeniedDialog(
          context,
          'Permiso de galería denegado',
          'Para seleccionar fotos, necesitamos acceso a tu galería.',
          await _isAndroid13OrHigher() ? Permission.photos : Permission.storage,
        );
        return null;
      } else if (galleryStatus.isPermanentlyDenied) {
        _showPermanentlyDeniedDialog(
          context,
          'Permiso de galería',
          'Has denegado permanentemente el acceso a la galería. Por favor, habilítalo en la configuración de la aplicación.',
        );
        return null;
      }
      
      return null;
    } catch (e) {
      _showErrorDialog(context, 'No se pudo acceder a la galería: $e');
      return null;
    }
  }

  /// Verifica el estado actual del permiso de cámara
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Verifica el estado actual del permiso de galería
  Future<bool> hasGalleryPermission() async {
    if (await _isAndroid13OrHigher()) {
      final status = await Permission.photos.status;
      return status.isGranted || status.isLimited;
    } else {
      final status = await Permission.storage.status;
      return status.isGranted;
    }
  }

  /// Determina si estamos en Android 13 o superior usando device_info_plus
  Future<bool> _isAndroid13OrHigher() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      
      // Android 13 = API Level 33
      // androidInfo.version.sdkInt contiene el API Level
      return androidInfo.version.sdkInt >= 33;
    } catch (e) {
      print('Error al obtener información del dispositivo: $e');
      // En caso de error, asumir versión antigua para mayor compatibilidad
      return false;
    }
  }

  /// Muestra diálogo cuando el permiso es denegado temporalmente
  void _showPermissionDeniedDialog(
    BuildContext context,
    String title,
    String message,
    Permission permission,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await permission.request();
              },
              child: const Text('Conceder permiso'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra diálogo cuando el permiso es denegado permanentemente
  void _showPermanentlyDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra diálogo de error genérico
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un bottom sheet con opciones de cámara y galería
  /// y maneja automáticamente los permisos
  Future<XFile?> showImageSourceBottomSheet(BuildContext context) async {
    return await showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromCamera(context);
                  if (context.mounted) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de la galería'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromGallery(context);
                  if (context.mounted) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}