import { io } from 'socket.io-client';
import type { Socket } from 'socket.io-client';
import {
  BaseSocketReceiveActions as SocketReceiveActions,
  BaseSocketEmitActions as SocketEmitActions,
} from '@/types/enums/socket-io.enum';

// const baseURL = '/api';
const baseURL = import.meta.env.VITE_APP_SERVICE_API_URL;

export class BaseSocket {
  protected socket: Socket | null = null;
  protected socketId: string = '';
  constructor(private url: string) {
    this.socket = io(`${baseURL}/${this.url}`);
  }

  public readonly handleNotSocket = () => {
    console.error('[error]: not socket instance');
  };

  public readonly getId = () => this.socketId || '';

  public readonly onConnect = async (callback?: Function) => {
    if (!this.socket) return this.handleNotSocket();
    this.socket.on(SocketReceiveActions.Connect, () => {
      if (callback) callback();
      this.socketId = this.socket?.id || '';
      console.log('[socket io] connection: ', this.getId());
    });
  };

  public readonly onDisconnect = (callback?: Function) => {
    if (!this.socket) return this.handleNotSocket();
    this.socket.on(SocketReceiveActions.Disconnect, () => {
      if (callback) callback();
      this.socket = null;
      this.socketId = '';
      console.log('[socket io] disconnection: ', this.getId());
    });
  };

  public readonly onChange = (callback?: Function) => {
    if (!this.socket) return this.handleNotSocket();
    this.socket.on(SocketReceiveActions.Change, (dto: any) => {
      if (callback) callback(dto);
      console.log('[socket io] receive change: ', this.getId());
    });
  };

  public readonly emitChange = (dto: any) => {
    if (!this.socket) return this.handleNotSocket();
    this.socket.emit(SocketEmitActions.Change, dto);
    console.log('[socket io] emit change: ', this.getId());
  };
}

const baseSocket = new BaseSocket('');

export default baseSocket;
