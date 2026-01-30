'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/utils/supabase/client'
import Link from 'next/link'
import { ChevronLeft, Plus, MapPin, Star, Building2, Loader2, ArrowRight } from 'lucide-react'

interface Clinic {
    id: string
    name: string
    address: string
    rating: string
    image: string
}

export default function HospitalsPage() {
    const [clinics, setClinics] = useState<Clinic[]>([])
    const [loading, setLoading] = useState(true)
    const supabase = createClient()

    useEffect(() => {
        fetchClinics()
    }, [])

    const fetchClinics = async () => {
        setLoading(true)
        const { data, error } = await supabase
            .from('clinics')
            .select('*')
            .order('name', { ascending: true })

        if (error) {
            console.error('Error fetching clinics:', error)
        } else {
            setClinics(data as Clinic[] || [])
        }
        setLoading(false)
    }

    return (
        <div className="min-h-screen bg-gray-50 p-6 sm:p-10">
            <div className="mx-auto max-w-7xl">

                {/* Header */}
                <div className="mb-8 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                    <div className="flex items-center gap-4">
                        <Link href="/" className="rounded-full bg-white p-2.5 text-gray-500 shadow-sm transition hover:bg-gray-100 hover:text-gray-700">
                            <ChevronLeft className="h-5 w-5" />
                        </Link>
                        <div>
                            <h1 className="text-3xl font-bold text-gray-900">Hospitals & Clinics</h1>
                            <p className="mt-1 text-sm text-gray-500">Manage registered healthcare facilities</p>
                        </div>
                    </div>
                    <Link
                        href="/hospitals/new"
                        className="inline-flex items-center rounded-xl bg-blue-600 px-5 py-2.5 text-sm font-medium text-white shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all hover:shadow-md"
                    >
                        <Plus className="mr-2 h-4 w-4" />
                        Add Facility
                    </Link>
                </div>

                {/* Content */}
                {loading ? (
                    <div className="flex h-64 items-center justify-center">
                        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
                    </div>
                ) : (
                    <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
                        {clinics.map((clinic) => (
                            <div key={clinic.id} className="group overflow-hidden rounded-2xl bg-white shadow-sm border border-gray-100 transition-all hover:shadow-md hover:border-blue-100">
                                <div className="aspect-[16/9] w-full overflow-hidden bg-gray-100 relative">
                                    {/* eslint-disable-next-line @next/next/no-img-element */}
                                    <img
                                        src={clinic.image || 'https://images.unsplash.com/photo-1587351021759-3e566b9af922?auto=format&fit=crop&q=80&w=800'}
                                        alt={clinic.name}
                                        className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
                                        onError={(e) => {
                                            (e.target as HTMLImageElement).src = 'https://images.unsplash.com/photo-1587351021759-3e566b9af922?auto=format&fit=crop&q=80&w=800'
                                        }}
                                    />
                                    <div className="absolute top-3 right-3 rounded-full bg-white/90 backdrop-blur-sm px-2 py-1 text-xs font-semibold text-gray-900 shadow-sm flex items-center">
                                        <Star className="mr-1 h-3 w-3 text-yellow-500 fill-yellow-500" />
                                        {clinic.rating}
                                    </div>
                                </div>

                                <div className="p-5">
                                    <div className="flex items-center gap-2 mb-2">
                                        <span className="inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-700/10">
                                            <Building2 className="mr-1 h-3 w-3" /> Clinic
                                        </span>
                                    </div>

                                    <h3 className="text-lg font-bold text-gray-900 group-hover:text-blue-600 transition-colors">
                                        {clinic.name}
                                    </h3>

                                    <div className="mt-2 flex items-start text-sm text-gray-500">
                                        <MapPin className="mr-1.5 h-4 w-4 flex-shrink-0 text-gray-400 mt-0.5" />
                                        <span className="line-clamp-2">{clinic.address}</span>
                                    </div>

                                    <div className="mt-5 pt-4 border-t border-gray-50 flex items-center justify-between">
                                        <span className="text-xs font-medium text-gray-400">ID: {clinic.id.slice(0, 8)}...</span>
                                        <button className="text-sm font-medium text-blue-600 hover:text-blue-800 flex items-center">
                                            Manage <ArrowRight className="ml-1 h-4 w-4" />
                                        </button>
                                    </div>
                                </div>
                            </div>
                        ))}

                        {/* Empty State Add Card */}
                        <Link href="/hospitals/new" className="group relative flex flex-col items-center justify-center rounded-2xl border-2 border-dashed border-gray-300 bg-gray-50/50 p-6 text-center hover:border-blue-500 hover:bg-blue-50/50 transition-all">
                            <div className="rounded-full bg-white p-4 shadow-sm group-hover:scale-110 transition-transform">
                                <Plus className="h-8 w-8 text-gray-400 group-hover:text-blue-500" />
                            </div>
                            <h3 className="mt-4 text-sm font-semibold text-gray-900">Register New Facility</h3>
                            <p className="mt-1 text-sm text-gray-500">Add a new hospital or clinic to the network</p>
                        </Link>
                    </div>
                )}
            </div>
        </div>
    )
}
