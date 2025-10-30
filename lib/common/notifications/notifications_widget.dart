import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/auth/supabase_auth/auth_util.dart';
import 'notifications_model.dart';
export 'notifications_model.dart';
import '/services/notification_service.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});

  static String routeName = 'Notifications';
  static String routePath = '/notifications';

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  late NotificationsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationsModel());
    // Configurar timeago en español si lo deseas
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: MediaQuery.sizeOf(context).height * 0.1,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).tertiary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0),
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.07,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: MediaQuery.sizeOf(context).width * 0.2,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              decoration: BoxDecoration(),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.safePop();
                                },
                                child: Icon(
                                  Icons.chevron_left_outlined,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 35.0,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.sizeOf(context).width * 0.6,
                              height: 100.0,
                              decoration: BoxDecoration(),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: AutoSizeText(
                                  'Notificaciones',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  minFontSize: 10.0,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.lexend(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontSize: 15.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.sizeOf(context).width * 0.2,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              decoration: BoxDecoration(),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  // Aquí llamamos al método para pedir permisos
                                  final notificationService = NotificationService();
                                  await notificationService.requestNotificationPermission();
                                  
                                  // Opcional: Mostrar un mensaje de confirmación
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Ya cuentas con los permisos de notificaciones'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.settings_rounded,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  size: 27.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 15.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            decoration: BoxDecoration(),
                            child: Builder(
                              builder: (context) {
                                final userId = currentUserUid;
                                
                                return StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: Supabase.instance.client
                                      .from('notifications')
                                      .stream(primaryKey: ['id'])
                                      .eq('recipient_id', userId)
                                      .order('created_at', ascending: false),
                                  builder: (context, snapshot) {
                                    if (userId.isEmpty) {
                                      return const Center(
                                        child: Text('Usuario no autenticado'),
                                      );
                                    }

                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Error cargando notificaciones'),
                                            Text('${snapshot.error}', style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      );
                                    }

                                    final allNotifications = snapshot.data ?? [];
                                    
                                    // Filtrar notificaciones de los últimos 30 días
                                    final notifications = allNotifications.where((notification) {
                                      final createdAt = notification['created_at'] as String?;
                                      if (createdAt == null) return false;
                                      
                                      try {
                                        final notificationDate = DateTime.parse(createdAt);
                                        final thirtyDaysAgoDate = DateTime.now().subtract(Duration(days: 30));
                                        return notificationDate.isAfter(thirtyDaysAgoDate);
                                      } catch (e) {
                                        return false; //  REMOVIDO: Log innecesario
                                      }
                                    }).toList();

                                    if (notifications.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.notifications_none,
                                              size: 64,
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'No tienes notificaciones',
                                              style: FlutterFlowTheme.of(context).bodyMedium,
                                            ),
                                            Text(
                                              'Las notificaciones de los últimos 30 días aparecerán aquí',
                                              style: FlutterFlowTheme.of(context).labelSmall,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      itemCount: notifications.length,
                                      itemBuilder: (context, index) {
                                        final notification = notifications[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context).width,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).alternate,
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                //  REMOVIDO: Logs innecesarios
                                                if (!notification['is_read']) {
                                                  try {
                                                    await Supabase.instance.client
                                                        .from('notifications')
                                                        .update({'is_read': true})
                                                        .eq('id', notification['id']);
                                                  } catch (e) {
                                                    // Fallar silenciosamente
                                                  }
                                                }
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Container(
                                                      width: MediaQuery.sizeOf(context).width * 0.1,
                                                      child: Icon(
                                                        notification['is_read']
                                                            ? Icons.notifications
                                                            : Icons.notifications_active,
                                                        color: notification['is_read']
                                                            ? FlutterFlowTheme.of(context).secondaryText
                                                            : FlutterFlowTheme.of(context).primary,
                                                        size: 30.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding: const EdgeInsets.all(10),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          //  CORREGIDO: Mostrar title + body en lugar de message
                                                          Text(
                                                            notification['title'] ?? 'Sin título',
                                                            style: FlutterFlowTheme.of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontWeight: notification['is_read'] 
                                                                      ? FontWeight.normal 
                                                                      : FontWeight.bold,
                                                                ),
                                                          ),
                                                          if (notification['body'] != null && notification['body'].isNotEmpty) ...[
                                                            SizedBox(height: 4),
                                                            Text(
                                                              notification['body'],
                                                              style: FlutterFlowTheme.of(context).bodySmall,
                                                            ),
                                                          ],
                                                          SizedBox(height: 4),
                                                          Text(
                                                            notification['created_at'] != null
                                                                ? timeago.format(
                                                                    DateTime.parse(notification['created_at']),
                                                                    locale: 'es',
                                                                  )
                                                                : 'Fecha desconocida',
                                                            style: FlutterFlowTheme.of(context).labelSmall,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}