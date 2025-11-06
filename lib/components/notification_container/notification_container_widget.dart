import 'package:dalk/user_provider.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'notification_container_model.dart';
export 'notification_container_model.dart';

class NotificationContainerWidget extends StatefulWidget {
  const NotificationContainerWidget({super.key});

  @override
  State<NotificationContainerWidget> createState() =>
      _NotificationContainerWidgetState();
}

class _NotificationContainerWidgetState
    extends State<NotificationContainerWidget> {
  late NotificationContainerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationContainerModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>().user;
    final String? userType = userProvider?.usertype; 
    final String userPrefix = userType == 'Dueño' ? 'owner' : 'walker';


    return Container(
      width: 393.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
        ),
        border: Border.all(
          color: FlutterFlowTheme.of(context).secondary,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Align(
              alignment: const AlignmentDirectional(1.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 5.0),
                child: Container(
                  decoration: const BoxDecoration(),
                  alignment: const AlignmentDirectional(1.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.push('/$userPrefix/notifications');
                    },
                    child: const Icon(
                      Icons.notifications_sharp,
                      color: Color(0xFFCCDBFF),
                      size: 32.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
